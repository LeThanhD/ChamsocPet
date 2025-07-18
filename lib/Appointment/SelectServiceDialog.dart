import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SelectServicePage extends StatefulWidget {
  final List<dynamic> existingServices;
  final String appointmentId;

  const SelectServicePage({
    super.key,
    required this.existingServices,
    required this.appointmentId,
  });

  @override
  _SelectServicePageState createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  final Set<String> selectedServiceIDs = {};
  List<dynamic> allServices = [];
  List<dynamic> dogServices = [];
  List<dynamic> catServices = [];
  bool isLoading = true;
  TextEditingController serviceController = TextEditingController();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    for (var service in widget.existingServices) {
      if (service['ServiceID'] != null) {
        selectedServiceIDs.add(service['ServiceID'].toString());
      }
    }
    fetchServices();
  }

  void updateServiceText() {
    final selectedNames = allServices
        .where((s) => selectedServiceIDs.contains(s['ServiceID'].toString()))
        .map((s) => s['ServiceName'])
        .join(', ');
    serviceController.text = selectedNames;
  }

  Future<void> fetchServices() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.108:8000/api/appointments/services'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        allServices = decoded['data'] ?? [];
        dogServices = allServices.where((s) => s['CategoryID'] == 'Chó').toList();
        catServices = allServices.where((s) => s['CategoryID'] == 'Mèo').toList();
        updateServiceText();
      } else {
        print('❌ Lỗi fetch dịch vụ: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception fetch service: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateSelectedServices(String appointmentId) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('❌ Token không hợp lệ');
        return;
      }

      final serviceIds = selectedServiceIDs.toList();
      print('📤 Gửi ServiceIDs: $serviceIds');

      final res = await http.put(
        Uri.parse('http://192.168.0.108:8000/api/appointments/update-service/$appointmentId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ServiceIDs': serviceIds}),
      );

      if (res.statusCode == 200) {
        print("✅ Cập nhật dịch vụ thành công");
      } else {
        print('❌ Lỗi cập nhật dịch vụ: ${res.body}');
      }
    } catch (e) {
      print('❌ Exception cập nhật dịch vụ: $e');
    }
  }

  Widget buildServiceList(String species) {
    final List<dynamic> speciesServices =
    species == 'Chó' ? dogServices : catServices;

    return ListView.builder(
      itemCount: speciesServices.length,
      itemBuilder: (_, i) {
        final service = speciesServices[i];
        final idStr = service['ServiceID'].toString();
        final isSelected = selectedServiceIDs.contains(idStr);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              service['ServiceName'] ?? 'Không tên',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (_) {
                setState(() {
                  if (isSelected) {
                    selectedServiceIDs.remove(idStr);
                  } else {
                    selectedServiceIDs.add(idStr);
                  }
                  updateServiceText();
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chọn Dịch Vụ"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          bottom: const  TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '🐶 Cho Chó'),
              Tab(text: '🐱 Cho Mèo'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: serviceController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Dịch vụ đã chọn',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  buildServiceList('Chó'),
                  buildServiceList('Mèo'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4)
                  ],
                ),
                child: const Text(
                  'Lưu dịch vụ',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () async {
                  await updateSelectedServices(widget.appointmentId);
                  Navigator.pop(context, selectedServiceIDs.toList());
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
