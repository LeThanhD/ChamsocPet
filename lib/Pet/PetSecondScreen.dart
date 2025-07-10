import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'EditPetScreen.dart';
import 'PetHistoryScreen.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  Map<String, dynamic>? pet;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPetDetail();
  }

  Future<void> fetchPetDetail() async {
    final url = Uri.parse('http://192.168.0.108:8000/api/pets/detail/${widget.petId}/all');

    try {
      final response = await http.get(url);

      print('🔁 Status code: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          pet = result['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (pet == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thú cưng')),
      );
    }

    final String name = pet!['Name'] ?? 'Không rõ';
    final String species = pet!['Species'] ?? 'Không rõ';
    final String breed = pet!['Breed'] ?? 'Không rõ';
    final String gender = pet!['Gender'] ?? 'Không rõ';
    final String color = pet!['FurColor'] ?? 'Không rõ';
    final String weight = pet!['Weight']?.toString() ?? 'Không rõ';
    final String dob = pet!['BirthDate'] ?? 'Không rõ';
    final String furType = pet!['fur_type'] ?? 'Không rõ';
    final String origin = pet!['origin'] ?? 'Không rõ';
    final String trained = pet!['trained'] == true ? 'Đã huấn luyện' : 'Chưa huấn luyện';
    final String healthNote = pet!['HealthNote'] ?? 'Không';
    final String vaccinated = pet!['vaccinated'] ?? 'Chưa tiêm';
    final String lastVaccineDate = pet!['latest_vaccine_date'] ?? 'Không rõ';
    final String owner = pet!['owner'] ?? 'Không rõ';

    final List<dynamic> vaccineNames = pet!['vaccine_names'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('🐾 $name'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2E9FB), Color(0xFFE3F8F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.teal),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 12),

                  _buildInfoRow(Icons.category, 'Loài', species),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.pets_outlined, 'Giống', breed),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.palette, 'Màu lông', color),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.monitor_weight, 'Cân nặng', '$weight kg'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.cake, 'Ngày sinh', dob),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.line_weight, 'Loại lông', furType),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.flag, 'Xuất xứ', origin),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.vaccines, 'Tiêm phòng', vaccinated),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.calendar_today, 'Ngày tiêm gần nhất', lastVaccineDate),

                  if (vaccineNames.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.list_alt, 'Danh sách vaccine', vaccineNames.join(', ')),
                  ],

                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.school, 'Huấn luyện', trained),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.note_alt, 'Ghi chú sức khoẻ', healthNote),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.wc, 'Giới tính', gender),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.person, 'Chủ nuôi', owner),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0BCFF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text("Chỉnh sửa thú cưng", style: TextStyle(fontSize: 16)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPetScreen(pet: pet!),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.history),
                      label: const Text("Xem lịch sử thuốc & dịch vụ", style: TextStyle(fontSize: 16)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetHistoryScreen(petId: pet!['PetID']),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
