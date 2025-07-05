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
    if (userId == null) return;
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
      Uri.parse('http://10.24.67.249:8000/api/pets/user/$userId'),
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
        if (pets.isNotEmpty) {
          selectedPetID = pets[0]['PetID']?.toString();
        }
      });
    }
  }

  Future<void> fetchServices() async {
    final response = await http.get(
      Uri.parse('http://10.24.67.249:8000/api/services/all'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> services = decoded['data']['data'];
      setState(() {
        serviceList = services;
        if (services.isNotEmpty) {
          selectedServiceID = services[0]['ServiceID']?.toString();
        }
      });
    }
  }

  Future<void> fetchStaff() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://10.24.67.249:8000/api/users/staff?role=staff'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      setState(() {
        staffList = data;
        if (data.isNotEmpty) {
          selectedStaffID = data[0]['UserID']?.toString();
        }
      });
    }
  }

  Future<void> fetchAvailableTimes(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse('http://10.24.67.249:8000/api/appointments/check-all?date=$dateStr'),
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

    final response = await http.post(
      Uri.parse('http://10.24.67.249:8000/api/appointments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'UserID': userId,
        'PetID': selectedPetID,
        'ServiceID': selectedServiceID,
        'AppointmentDate': selectedDate!.toIso8601String().split('T')[0],
        'AppointmentTime': '$selectedTime:00',
        'Reason': noteController.text.trim().isNotEmpty ? noteController.text.trim() : 'Không có ghi chú',
        'Status': 'Chưa duyệt',
        'StaffID': selectedStaffID,
      }),
    );

    if (response.statusCode == 201) {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }


  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, void Function(String?)? onChanged) {
    final currentValueExists = value != null && items.any((item) => item.value == value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: currentValueExists ? value : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
            colors: [Color(0xFFF2E8FF), Color(0xFFD2F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0D9F2), Color(0xFFB6F5FB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Ink(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5DBF5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Lịch hẹn',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdown(
                      'Thú cưng',
                      selectedPetID,
                      petList.map((pet) => DropdownMenuItem<String>(
                        value: pet['PetID']?.toString(),
                        child: Text(pet['Name'] ?? 'Không tên'),
                      )).toList(),
                          (value) => setState(() => selectedPetID = value),
                    ),
                    _buildDropdown(
                      'Dịch vụ',
                      selectedServiceID,
                      serviceList.map((s) => DropdownMenuItem<String>(
                        value: s['ServiceID']?.toString(),
                        child: Text(s['ServiceName']),
                      )).toList(),
                          (value) => setState(() => selectedServiceID = value),
                    ),
                    _buildDropdown(
                      'Nhân viên (tuỳ chọn)',
                      selectedStaffID,
                      staffList.map((s) => DropdownMenuItem<String>(
                        value: s['UserID']?.toString(),
                        child: Text(s['FullName']),
                      )).toList(),
                          (value) => setState(() => selectedStaffID = value),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedDate != null ? selectedDate!.toIso8601String().split('T')[0] : '',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                          await fetchAvailableTimes(picked);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Ngày hẹn',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    _buildDropdown(
                      'Giờ hẹn',
                      selectedTime,
                      availableTimes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          (value) => setState(() => selectedTime = value),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú (tuỳ chọn)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: submitAppointment,
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: const Text('Đặt lịch hẹn', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
