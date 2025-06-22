import 'package:flutter/material.dart';
import '../Page/PageScreen.dart';
import '../Quản Lý/ManageScreen.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? selectedTime;
  String? selectedService;
  String? selectedPetName;

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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PageScreen()),
                    );
                  },
                ),
                const Spacer(),
                const Text(
                  'Đặt lịch hẹn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 24),

            // Chọn thú cưng
            _buildPetField(context),

            // Tên khách hàng
            _buildTextField('Tên khách hàng', customerNameController),

            // Ngày hẹn & Giờ hẹn
            Row(
              children: [
                Expanded(child: _buildDatePicker(context, 'Ngày hẹn')),
                const SizedBox(width: 8),
                Expanded(child: _buildTimeDropdown()),
              ],
            ),

            // Dịch vụ
            _buildServiceDropdown(),

            // Ghi chú
            _buildTextField('Ghi chú', noteController),

            const SizedBox(height: 24),

            // Nút đặt hẹn
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
                onPressed: () {
                  // TODO: handle submission
                },
                child: const Text('Đặt hẹn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 32),

            const Center(
              child: Text(
                'GIỜ LÀM VIỆC',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTimeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedTime ?? '12:00',
        decoration: const InputDecoration(
          labelText: 'Giờ hẹn',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00']
            .map((time) => DropdownMenuItem<String>(
          value: time,
          child: Text(time),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedTime = value;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Ngày hẹn',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          await showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
        },
      ),
    );
  }

  Widget _buildServiceDropdown() {
    final services = [
      'Cấp cứu 24/7',
      'Khám định kỳ/tổng quát',
      'Tắm Sấy, Spa và Cắt Tỉa',
      'Tiêm phòng vaccine',
      'Triệt Sản Chó Mèo',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedService,
        onChanged: (value) {
          setState(() {
            selectedService = value;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Dịch vụ',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: services.map((service) {
          return DropdownMenuItem<String>(
            value: service,
            child: Text(service),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPetField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: selectedPetName ?? ''),
        decoration: const InputDecoration(
          labelText: 'Thú cưng',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(Icons.pets),
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageScreen()),
          );
          if (result != null && result is String) {
            setState(() {
              selectedPetName = result;
            });
          }
        },
      ),
    );
  }
}
