import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String? selectedStaffID;
  DateTime? selectedDate;

  List<String> availableTimes = [];
  List<dynamic> petList = [];
  List<dynamic> serviceList = [];
  List<dynamic> staffList = [];

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
    await fetchStaff();
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
    }
  }

  Future<void> fetchServices() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/services/all'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> services = decoded['data']['data'];
      setState(() {
        serviceList = services;
        if (services.isNotEmpty) {
          selectedServiceName = services[0]['ServiceName'];
          selectedServiceID = services[0]['ServiceID'].toString();
        }
      });
    }
  }

  Future<void> fetchStaff() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/users/staff?role=staff'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      setState(() {
        staffList = data;
        if (staffList.isNotEmpty) {
          selectedStaffID = staffList[0]['UserID'].toString();
        }
      });
    }
  }

  Future<void> fetchAvailableTimes(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/appointments/check-all?date=$dateStr'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<String> allSlots = [
        "08:00", "09:00", "10:00", "11:00",
        "14:00", "15:00", "16:00", "17:00"
      ];
      final List<String> booked = List<String>.from(decoded['booked_times'] ?? []);

      setState(() {
        availableTimes = allSlots.where((time) => !booked.contains(time)).toList();
        if (!availableTimes.contains(selectedTime)) selectedTime = null;
      });
    } else {
      setState(() {
        availableTimes = [];
        selectedTime = null;
      });
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
    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập lại")),
      );
      return;
    }

    String formattedTime = "$selectedTime:00";

    final response = await http.post(
      Uri.parse('http://192.168.0.108:8000/api/appointments'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'UserID': userId,
        'PetID': selectedPetID,
        'ServiceID': selectedServiceID,
        'AppointmentDate': selectedDate!.toIso8601String().split('T')[0],
        'AppointmentTime': formattedTime,
        'Reason': noteController.text,
        'Status': 'Chưa duyệt',
        'StaffID': selectedStaffID,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đặt hẹn thành công')),
      );

      await http.post(
        Uri.parse('http://192.168.0.108:8000/api/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'title': 'Lịch hẹn mới',
          'body': 'Lịch hẹn của bạn đã được tạo và đang chờ duyệt.',
        }),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi đặt hẹn (${response.statusCode})')),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Thêm lịch hẹn',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Remaining UI code here (Dropdowns, date/time, notes, etc.)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
