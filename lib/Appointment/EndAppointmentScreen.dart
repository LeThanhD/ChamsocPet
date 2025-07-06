import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EndAppointmentScreen extends StatefulWidget {
  final String appointmentId;
  final String petId;

  const EndAppointmentScreen({
    Key? key,
    required this.appointmentId,
    required this.petId,
  }) : super(key: key);

  @override
  State<EndAppointmentScreen> createState() => _EndAppointmentScreenState();
}

class _EndAppointmentScreenState extends State<EndAppointmentScreen> {
  bool isLoading = false;
  List<dynamic> medicines = [];
  Set<String> selectedMedicineIds = {};
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> fetchMedicines() async {
    final token = await getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/medications'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        medicines = decoded['data'];
      });
    } else {
      print('❌ Lỗi lấy thuốc: ${response.body}');
    }
  }

  void updateTotal() {
    double total = 0.0;
    for (var med in medicines) {
      if (selectedMedicineIds.contains(med['MedicationID'])) {
        total += double.tryParse(med['Price'].toString()) ?? 0.0;
      }
    }
    setState(() {
      totalAmount = total;
    });
  }

  Future<void> endAppointmentAndCreateInvoice() async {
    setState(() => isLoading = true);
    final token = await getToken();
    final userId = await getUserId();
    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng đăng nhập lại')),
      );
      return;
    }

    final endRes = await http.put(
      Uri.parse('http://192.168.0.108:8000/api/appointments/end/${widget.appointmentId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (endRes.statusCode != 200) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi kết thúc cuộc hẹn')),
      );
      return;
    }

    final res = await http.post(
      Uri.parse('http://192.168.0.108:8000/api/invoices'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'PetID': widget.petId,
        'medicine_ids': selectedMedicineIds.toList(),
      }),
    );

    setState(() => isLoading = false);

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final total = data['TotalAmount'] ?? totalAmount;
      final serviceName = data['ServiceName'] ?? 'Không rõ';

      final medicineNames = medicines
          .where((m) => selectedMedicineIds.contains(m['MedicationID']))
          .map((m) => m['Name'])
          .join(', ');

      await http.post(
        Uri.parse('http://192.168.0.108:8000/api/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'title': 'Hóa đơn đã tạo',
          'body': 'Dịch vụ: $serviceName\nThuốc: ${medicineNames.isNotEmpty ? medicineNames : 'Không có'}\nTổng tiền: ${total.toStringAsFixed(0)}đ',
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Hóa đơn đã tạo. Tổng tiền: ${total.toStringAsFixed(0)}đ'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(context, '/invoice-list');
    } else {
      print('❌ Lỗi tạo hóa đơn: ${res.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi tạo hóa đơn')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết thúc lịch hẹn')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('🧾 Chọn thuốc kê đơn:', style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                final id = med['MedicationID'];
                return CheckboxListTile(
                  title: Text('${med['Name']} (${med['Price']}đ)'),
                  subtitle: Text(med['Instructions'] ?? ''),
                  value: selectedMedicineIds.contains(id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedMedicineIds.add(id);
                      } else {
                        selectedMedicineIds.remove(id);
                      }
                    });
                    updateTotal();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${totalAmount.toStringAsFixed(0)}đ', style: const TextStyle(fontSize: 18, color: Colors.red)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Kết thúc và tạo hóa đơn'),
              onPressed: endAppointmentAndCreateInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}