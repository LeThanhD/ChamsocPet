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
  List<dynamic> services = [];
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
    final selectedNames = services
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
        services = decoded['data'] ?? [];
        updateServiceText(); // cập nhật textfield sau khi load xong
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn Dịch Vụ"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: serviceController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Dịch vụ đã chọn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (_, i) {
                  final service = services[i];
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
                            updateServiceText(); // cập nhật ô text
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          onPressed: () async {
            await updateSelectedServices(widget.appointmentId);
            Navigator.pop(context, selectedServiceIDs.toList());
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
