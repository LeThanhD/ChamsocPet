import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MedicinePage.dart';
import 'EditMedicineScreen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  late Medicine medicine;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    medicine = widget.medicine;
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    setState(() => isAdmin = role == 'staff');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: 0,
          title: const Text('Chi tiết thuốc', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: medicine.imageUrl.isNotEmpty
                  ? Image.network(
                medicine.imageUrl,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
              )
                  : const Icon(Icons.medical_services, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              medicine.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${medicine.price} đ',
              style: const TextStyle(fontSize: 22, color: Colors.deepOrange),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mô tả sản phầm:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medicine.instructions.isNotEmpty ? medicine.instructions : 'Không có hướng dẫn.',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            if (isAdmin)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditMedicineScreen(medicine: medicine),
                      ),
                    );

                    if (result != null && result is Medicine) {
                      setState(() => medicine = result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Đã cập nhật')),
                      );
                      Navigator.pop(context, 'refresh'); // thông báo về để reload danh sách
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa thuốc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
