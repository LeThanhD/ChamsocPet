import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final user = appointment['user'] ?? {};
    final pet = appointment['pet'] ?? {};
    final servicesRaw = appointment['services'] ?? [];

    // Chuyển về List<Map> cho chắc chắn
    final List<Map<String, dynamic>> services = [];
    if (servicesRaw is List) {
      for (var s in servicesRaw) {
        if (s is Map<String, dynamic>) {
          services.add(s);
        } else if (s is Map) {
          services.add(Map<String, dynamic>.from(s));
        }
      }
    }

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
                  _buildServicesList(services),
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
      color: const Color(0xFFF3E8FF), // nền tím nhạt nhẹ nhàng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A), // tím đậm
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C), // tím vừa phải
              )),
          Expanded(child: Text(value?.toString() ?? '', style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<Map<String, dynamic>> services) {
    if (services.isEmpty) {
      return const Text('Không có dịch vụ',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: services.map<Widget>((service) {
        final name = service['ServiceName'] ?? 'Không rõ';
        final price = service['Price'] ?? 0;
        final priceFormatted = _formatPrice(price);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Text('• ', style: TextStyle(fontSize: 20, color: Color(0xFF6A1B9A))),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF4A148C)),
                ),
              ),
              Text(
                '$priceFormatted VNĐ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A), fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    try {
      final p = price is String ? double.tryParse(price) ?? 0 : price.toDouble();
      return p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    } catch (_) {
      return price.toString();
    }
  }
}
