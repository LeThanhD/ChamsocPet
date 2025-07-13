import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  bool isLoading = false;
  Map<String, dynamic>? statisticsData;

  Future<void> fetchStatistics() async {
    if (fromDate == null || toDate == null) return;

    setState(() => isLoading = true);

    final url = Uri.parse(
        'http://192.168.0.108:8000/api/statistics?from=${fromDate!.toIso8601String().split('T').first}&to=${toDate!.toIso8601String().split('T').first}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          statisticsData = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Lỗi: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: isFrom ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
      selectableDayPredicate: isFrom
          ? null
          : (day) => fromDate == null || !day.isBefore(fromDate!),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          toDate = null;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Widget _buildStatisticsBlock({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          child
        ],
      ),
    );
  }

  Widget _buildStatisticsResult() {
    if (statisticsData == null) {
      return const Text("📭 Chưa có dữ liệu thống kê",
          style: TextStyle(fontSize: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatisticsBlock(
          title: '📊 Tổng quan',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text("🔢 Tổng lượt đăng ký khám: ${statisticsData!['totalAppointments']}"),
              Text("🐾 Tổng số thú cưng đến khám: ${statisticsData!['totalPets']}"),
            ],
          ),
        ),
        _buildStatisticsBlock(
          title: '🐶 Thú cưng theo loài',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              (statisticsData!['petsBySpecies'] as List).length,
                  (index) {
                final item = statisticsData!['petsBySpecies'][index];
                return Text("• ${item['Species']}: ${item['count']}",
                    style: const TextStyle(fontSize: 15));
              },
            ),
          ),
        ),
        _buildStatisticsBlock(
          title: '💆‍♂️ Tỷ lệ sử dụng dịch vụ',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              (statisticsData!['servicesPercentage'] as List).length,
                  (index) {
                final item = statisticsData!['servicesPercentage'][index];
                return Text(
                  "• ${item['ServiceName']}: ${item['count']} lượt (${item['percentage']}%)",
                  style: const TextStyle(fontSize: 15),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEDCFD), Color(0xFFC6EDFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.bar_chart, color: Colors.teal, size: 30),
                          SizedBox(width: 8),
                          Text("Thống kê dịch vụ",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold))
                        ]),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.date_range, color: Colors.white),
                                label: Text(
                                  fromDate == null
                                      ? "Chọn ngày bắt đầu"
                                      : "Từ: ${fromDate!.toIso8601String().split('T').first}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onPressed: () => _pickDate(isFrom: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.date_range_outlined, color: Colors.white),
                                label: Text(
                                  toDate == null
                                      ? "Chọn ngày kết thúc"
                                      : "Đến: ${toDate!.toIso8601String().split('T').first}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onPressed: fromDate == null
                                    ? null
                                    : () => _pickDate(isFrom: false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: fromDate == null
                                      ? Colors.grey
                                      : Colors.teal.shade300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: isLoading
                                ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ))
                                : const Icon(Icons.search, color: Colors.white),
                            label: const Text("Lấy thống kê",
                                style: TextStyle(color: Colors.white)),
                            onPressed: (fromDate != null && toDate != null)
                                ? fetchStatistics
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (fromDate != null && toDate != null)
                                  ? Colors.teal
                                  : Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStatisticsResult(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
