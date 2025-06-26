import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AppointmentPage.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController noteController = TextEditingController();

  String? userId;
  String? selectedTime;
  String? selectedPetID;
  String? selectedServiceID;
  String? selectedServiceName;
  DateTime? selectedDate;

  List<dynamic> petList = [];
  List<dynamic> serviceList = [];

  @override
  void initState() {
    super.initState();
    initUserData();
  }

  Future<void> initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    if (userId == null || userId!.isEmpty) return;

    await fetchPets();
    await fetchServices();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchPets() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/pets/user/$userId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> pets = decoded is List ? decoded : decoded['data'] ?? [];

      setState(() {
        petList = pets;
        if (petList.isNotEmpty) {
          selectedPetID = petList[0]['PetID'].toString();
        }
      });
    } else {
      print('❌ fetchPets failed: ${response.body}');
    }
  }

  Future<void> fetchServices() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/services/all'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> services = decoded['data']['data'];

        setState(() {
          serviceList = services;
          if (services.isNotEmpty) {
            selectedServiceName = services[0]['ServiceName']?.toString();
            selectedServiceID = services[0]['ServiceID']?.toString();
          }
        });
      } catch (e) {
        print('❌ Error parsing service list: $e');
      }
    } else {
      print('❌ fetchServices failed: ${response.body}');
    }
  }

  Future<void> updatePetNoteService() async {
    final response = await http.put(
      Uri.parse('http://192.168.0.108:8000/api/pet-notes/update-service'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'PetID': selectedPetID,
        'ServiceID': selectedServiceID,
      }),
    );

    if (response.statusCode != 200) {
      print("⚠️ Lỗi cập nhật ServiceID trong PetNotes: ${response.body}");
    }
  }

  Future<void> submitAppointment() async {
    if (selectedPetID == null || selectedServiceID == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đầy đủ thông tin")),
      );
      return;
    }

    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token không tồn tại. Vui lòng đăng nhập lại.")),
      );
      return;
    }

    String formattedTime = selectedTime!;
    if (formattedTime.length == 5) {
      formattedTime = '$formattedTime:00';
    }

    final response = await http.post(
      Uri.parse('http://192.168.0.108:8000/api/appointments'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'PetID': selectedPetID,
        'ServiceID': selectedServiceID,
        'AppointmentDate': selectedDate!.toIso8601String().split('T')[0],
        'AppointmentTime': formattedTime,
        'Reason': noteController.text,
        'Status': 'Chưa duyệt',
      }),
    );

    if (response.statusCode == 201) {
      await updatePetNoteService();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hẹn thành công')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppointmentPage(appointmentData: {},)),
      );
    } else {
      print('Appointment API Error: ${response.statusCode}');
      print('Body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đặt hẹn (${response.statusCode})')),
      );
    }
  }

  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, void Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: items.any((item) => item.value == value) ? value : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAEE1F9), Color(0xFF83EAF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: ListView(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text('Đặt lịch hẹn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),
            _buildDropdown(
              'Thú cưng',
              selectedPetID,
              petList.map((pet) => DropdownMenuItem<String>(
                value: pet['PetID'].toString(),
                child: Text(pet['Name']),
              )).toList(),
                  (value) => setState(() => selectedPetID = value),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedDate != null ? selectedDate!.toIso8601String().split('T')[0] : '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Ngày hẹn',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    'Giờ hẹn',
                    selectedTime,
                    List.generate(10, (i) => '${8 + i}:00').map((time) => DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    )).toList(),
                        (value) => setState(() => selectedTime = value),
                  ),
                ),
              ],
            ),
            _buildDropdown(
              'Dịch vụ',
              selectedServiceName,
              serviceList.map((service) => DropdownMenuItem<String>(
                value: service['ServiceName']?.toString(),
                child: Text(service['ServiceName'] ?? ''),
              )).toList(),
                  (value) {
                setState(() {
                  selectedServiceName = value;
                  final matched = serviceList.firstWhere(
                        (s) => s['ServiceName']?.toString() == value,
                    orElse: () => null,
                  );
                  if (matched != null) {
                    selectedServiceID = matched['ServiceID']?.toString();
                  }
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: submitAppointment,
                child: const Text('Đặt hẹn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text('GIỜ LÀM VIỆC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thứ 2 - Chủ nhật : Sáng 08h00 - 12h00,\nChiều 14h00 - 18h00',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
