import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AddMedicine.dart';
import 'MedicineDetailScreen.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  late Future<List<Medicine>> medicines;
  List<Medicine> filteredMedicines = [];
  bool isAdmin = false;
  String searchQuery = '';
  bool isSearching = false;
  bool isLoading = false;
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _refreshMedicines();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    setState(() {
      isAdmin = role == 'staff';
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _refreshMedicines() {
    setState(() {
      medicines = fetchMedicines();
    });
  }

  Future<List<Medicine>> fetchMedicines() async {
    setState(() => isLoading = true);
    final token = await _getToken();

    final uri = Uri.parse('http://192.168.0.108:8000/api/medications')
        .replace(queryParameters: {
      if (searchQuery.isNotEmpty) 'search': searchQuery,
      'page': '1',
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      final meds = data.map((json) => Medicine.fromJson(json)).toList();
      filteredMedicines = meds;
      return meds;
    } else {
      throw Exception('Không thể tải danh sách thuốc');
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value;
      });
      _refreshMedicines();
    });
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
      _searchController.clear();
    });
    _refreshMedicines();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: isSearching
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: _cancelSearch,
      )
          : const BackButton(color: Colors.black),
      title: isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Tìm thuốc...',
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: isLoading
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
                width: 16,
                height: 16,
                child:
                CircularProgressIndicator(strokeWidth: 2)),
          )
              : IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          ),
        ),
      )
          : const Text('Danh Sách Thuốc',
          style: TextStyle(color: Colors.black)),
      actions: isSearching
          ? []
          : [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: _startSearch,
        )
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Medicine>>(
                future: medicines,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      filteredMedicines.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('❌ Lỗi: ${snapshot.error}'));
                  }

                  if (filteredMedicines.isEmpty) {
                    return const Center(
                        child: Text('🧪 Không tìm thấy thuốc nào'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (_, index) => MedicineItem(
                      medicine: filteredMedicines[index],
                      onUpdated: _refreshMedicines,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMedicineScreen()),
          );
          if (result == 'refresh') {
            _refreshMedicines();
          }
        },
      )
          : null,
    );
  }
}

// ================== Model & Item Widget ==================

class Medicine {
  final String id;
  final String name;
  final int price;
  final String instructions;
  final String imageUrl;

  Medicine({
    required this.id,
    required this.name,
    required this.price,
    required this.instructions,
    required this.imageUrl,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['MedicationID'].toString(),
    name: json['Name'] ?? '',
    price: json['Price'] ?? 0,
    instructions: json['UsageInstructions'] ?? '',
    imageUrl: json['ImageURL'] ?? '',
  );
}

class MedicineItem extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onUpdated;

  const MedicineItem({required this.medicine, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: medicine.imageUrl.isNotEmpty
              ? Image.network(
            medicine.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          )
              : const Icon(Icons.medical_services,
              size: 50, color: Colors.grey),
        ),
        title: Text(
          medicine.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(medicine.instructions),
        trailing: Text(
          '${medicine.price} đ',
          style: const TextStyle(
              color: Colors.deepOrange, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicineDetailScreen(medicine: medicine),
            ),
          );
          if (result == 'refresh') {
            onUpdated();
          }
        },
      ),
    );
  }
}
