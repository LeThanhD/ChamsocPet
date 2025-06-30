import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final user = appointment['user'] ?? {};
    final pet = appointment['pet'] ?? {};
    final service = appointment['service'] ?? {};
    final staff = appointment['staff'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch hẹn'),
        centerTitle: true,
        backgroundColor: const Color(0xFF9FF3F9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSectionCard('📅 Thông tin lịch hẹn', [
                  _buildDetailRow('Mã lịch hẹn', appointment['AppointmentID']),
                  _buildDetailRow('Ngày', appointment['AppointmentDate']),
                  _buildDetailRow('Giờ', appointment['AppointmentTime']),
                  _buildDetailRow('Trạng thái', appointment['Status']),
                  _buildDetailRow('Ghi chú', appointment['Reason'] ?? 'Không có'),
                ]),
                const SizedBox(height: 16),
                _buildSectionCard('🐶 Thông tin thú cưng', [
                  _buildDetailRow('Tên', pet['Name']),
                ]),
                const SizedBox(height: 16),
                _buildSectionCard('🧍 Thông tin chủ nuôi', [
                  _buildDetailRow('Tên', user['FullName']),
                ]),
                const SizedBox(height: 16),
                _buildSectionCard('💼 Thông tin dịch vụ', [
                  _buildDetailRow('Dịch vụ', service['ServiceName']),
                  _buildDetailRow('Giá', '${service['Price'] ?? ''} VNĐ'),
                ]),
                const SizedBox(height: 16),
                _buildSectionCard('👨‍🔧 Nhân viên phụ trách', [
                  _buildDetailRow('Tên', staff['FullName'] ?? staff['name'] ?? 'Không rõ'),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? '')),
        ],
      ),
    );
  }
}
