import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  late Future<List<Medicine>> medicines;

  @override
  void initState() {
    super.initState();
    medicines = fetchMedicines();
  }

  // Fetch list of medicines from the API
  Future<List<Medicine>> fetchMedicines() async {
    final url = Uri.parse('http://192.168.0.108:8000/api/medications');
    final token = await _getToken(); // Get the token from SharedPreferences

    // Send request with the Authorization token
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',  // Send token in the Authorization header
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      try {
        final jsonBody = jsonDecode(response.body);
        print('API Response: $jsonBody');  // Kiểm tra phản hồi API

        final List<dynamic> data = jsonBody['data'];  // Lấy dữ liệu từ trường 'data'
        return data.map((item) => Medicine.fromJson(item)).toList();
      } catch (e) {
        print('Lỗi phân tích cú pháp phản hồi: $e');
        throw Exception('Lỗi phân tích cú pháp phản hồi');
      }
    } else {
      print('Không thể tải dữ liệu: ${response.statusCode}');
      print('Phản hồi: ${response.body}');
      throw Exception('Không thể tải danh sách thuốc');
    }
  }

  // Lấy token từ SharedPreferences để sử dụng cho API request
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Danh Sách Thuốc'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // QUAY LẠI
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: FutureBuilder<List<Medicine>>(
          future: medicines,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Không có dữ liệu'));
            }

            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return MedicineItem(medicine: items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class Medicine {
  final String name;
  final String imageUrl;
  final String instructions;
  final int price;

  Medicine({
    required this.name,
    required this.imageUrl,
    required this.instructions,
    required this.price,
  });

  // Convert JSON data into Medicine object
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['Name'] ?? 'Không tên',
      imageUrl: json['ImageURL'] ?? '', // Handle the case when image URL is null
      instructions: json['UsageInstructions'] ?? 'Không có mô tả',
      price: json['Price'] ?? 0,
    );
  }
}

class MedicineItem extends StatelessWidget {
  final Medicine medicine;

  const MedicineItem({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image of the medicine if available, otherwise show placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: medicine.imageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(medicine.imageUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: medicine.imageUrl.isEmpty
                  ? Icon(Icons.image_not_supported, size: 30, color: Colors.grey)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine name with bold font and a bit larger size
                  Text(
                    medicine.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8),
                  // Price of the medicine
                  Text(
                    '${medicine.price} đ',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.deepOrange),
                  ),
                  SizedBox(height: 8),
                  // Instructions for usage
                  Text(
                    medicine.instructions,
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
