import 'package:flutter/material.dart';
import 'EditPetScreen.dart';
import 'PetHistoryScreen.dart';  // Import màn hình lịch sử thuốc & dịch vụ

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = pet['Name'] ?? 'Không rõ';
    final String species = pet['Species'] ?? 'Không rõ';
    final String breed = pet['Breed'] ?? 'Không rõ';
    final String gender = pet['Gender'] ?? 'Không rõ';
    final String color = pet['FurColor'] ?? 'Không rõ';
    final String weight = pet['Weight']?.toString() ?? 'Không rõ';
    final String dob = pet['BirthDate'] ?? 'Không rõ';

    final String healthNote = (pet['latestNote'] ?? pet['latest_note'])?['Content'] ?? 'Không';

    final String furType = pet['fur_type'] ?? 'Không rõ';
    final String origin = pet['origin'] ?? 'Không rõ';
    final String vaccinated = pet['vaccinated'] == true ? 'Đã tiêm' : 'Chưa tiêm';
    final String lastVaccineDate = pet['last_vaccine_date'] ?? 'Không rõ';
    final String trained = pet['trained'] == true ? 'Đã huấn luyện' : 'Chưa huấn luyện';
    final String? ownerName = pet['user'] != null ? pet['user']['FullName'] : null;

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
                  Text(
                    name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
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
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.school, 'Huấn luyện', trained),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.note_alt, 'Ghi chú sức khoẻ', healthNote),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.wc, 'Giới tính', gender),
                  if (ownerName != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.person, 'Chủ nuôi', ownerName),
                  ],

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
                            builder: (context) => EditPetScreen(pet: pet),
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
                            builder: (context) => PetHistoryScreen(petId: pet['PetID']),
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
        Text(
          '$label:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
