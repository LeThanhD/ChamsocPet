import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppointmentDetailPage.dart';
import 'AppointmentHistory.dart';
import 'AppointmentScreen.dart';
import 'SelectServiceDialog.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  AppointmentPageState createState() => AppointmentPageState();
}

class AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> appointments = [];
  String? role;
  String? userId;
  bool isLoading = false;
  bool isSearching = false;
  final searchController = TextEditingController();

  // Thứ tự trạng thái ưu tiên sắp xếp
  final List<String> statusOrder = [
    'Chưa duyệt',
    'Đã duyệt',
    'Chờ khám',
    'Đang khám',
    'Hoàn tất dịch vụ',
    'Chờ thêm thuốc',
    'Kết thúc',
  ];

  @override
  void initState() {
    super.initState();
    loadUserAndFetchAppointments();
  }

  Future<void> loadUserAndFetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    role = prefs.getString('role');
    await fetchAppointments();
  }

  Future<List<dynamic>> fetchMedications() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/medications/in'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa lịch hẹn này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.108:8000/api/appointments/$appointmentId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa lịch hẹn thành công')),
        );
        await fetchAppointments();
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final String message = body['message'] ?? 'Lỗi không xác định';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> fetchAppointments({String query = ''}) async {
    setState(() => isLoading = true);
    String url;

    if (role == 'staff') {
      url = 'http://192.168.0.108:8000/api/appointments/every?role=staff';
      if (query.isNotEmpty) url += '&search=$query';
    } else {
      url = 'http://192.168.0.108:8000/api/appointments/all?UserID=$userId';
      if (query.isNotEmpty) url += '&search=$query';
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];

        if (data is List) {
          List<Map<String, dynamic>> loadedAppointments = List<Map<String, dynamic>>.from(data)
              .where((a) => a['Status'] != 'Kết thúc')
              .toList();

          // Sắp xếp theo statusOrder
          loadedAppointments.sort((a, b) {
            final indexA = statusOrder.indexOf(a['Status'] ?? '');
            final indexB = statusOrder.indexOf(b['Status'] ?? '');
            return indexA.compareTo(indexB);
          });

          setState(() {
            appointments = loadedAppointments;
          });
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Hàm xây dựng widget hiển thị tag trạng thái màu sắc rõ ràng
  Widget buildStatusTag(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Chưa duyệt':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'Đã duyệt':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Chờ khám':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'Đang khám':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;
      case 'Hoàn tất dịch vụ':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Chờ thêm thuốc':
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade800;
        break;
      case 'Kết thúc':
        backgroundColor = Colors.grey.shade400;
        textColor = Colors.grey.shade900;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget statusActions(String current, String id, List<dynamic> services) {
    final Map<String, List<String>> next = {
      'Chưa duyệt': ['Đã duyệt'],
      'Đã duyệt': ['Chờ khám'],
      'Chờ khám': ['Đang khám'],
      'Đang khám': ['Hoàn tất dịch vụ'],
      'Hoàn tất dịch vụ': ['Chờ thêm thuốc'],
      'Chờ thêm thuốc': ['Kết thúc'],
    };

    return Row(
      children: next[current]?.map((s) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: () async {
              if (s == 'Hoàn tất dịch vụ' && role == 'staff') {
                final existingServices = (services as List).where((s) =>
                s['ServiceID'] != null && s['ServiceName'] != null).toList();

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectServicePage(
                      existingServices: existingServices,
                      appointmentId: id,
                    ),
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  print('📦 Dịch vụ đã chọn: $result');
                  await fetchAppointments();
                }
              } else {
                await updateStatus(id, s);
                await fetchAppointments();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(s, style: const TextStyle(color: Colors.white)),
          ),
        );
      }).toList() ?? [],
    );
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    try {
      if (status == 'Kết thúc') {
        final meds = await fetchMedications();
        final selectedMeds = await showDialog<List>(
          context: context,
          barrierDismissible: false,
          builder: (_) => SelectMedicineDialog(meds),
        );

        if (selectedMeds == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❗Bạn đã hủy chọn thuốc')),
          );
          return;
        }

        List<Map<String, dynamic>> medIds = [];
        for (var med in selectedMeds) {
          medIds.add({'id': med['MedicationID'], 'quantity': 1});
        }

        final invoiceRes = await http.post(
          Uri.parse('http://192.168.0.108:8000/api/invoices'),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'appointment_id': appointmentId, 'medicine_ids': medIds}),
        );

        if (!(invoiceRes.statusCode == 200 || invoiceRes.statusCode == 201)) {
          print('❌ Lỗi tạo hóa đơn: ${invoiceRes.body}');
          return;
        }

        final updateRes = await http.put(
          Uri.parse('http://192.168.0.108:8000/api/appointments/update-status/$appointmentId'),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'Status': 'Kết thúc'}),
        );

        if (updateRes.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Đã kết thúc và tạo hóa đơn')),
          );
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentHistoryPage()),
          );
        } else {
          print('❌ Lỗi cập nhật trạng thái: ${updateRes.body}');
        }
        return;
      }

      final res = await http.put(
        Uri.parse('http://192.168.0.108:8000/api/appointments/update-status/$appointmentId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'Status': status}),
      );

      if (res.statusCode == 200) {
        setState(() {
          final index = appointments.indexWhere((a) => a['AppointmentID'] == appointmentId);
          if (index != -1) appointments[index]['Status'] = status;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Đã cập nhật trạng thái: $status')),
        );
      } else {
        print('❌ Lỗi duyệt: ${res.body}');
      }
    } catch (e) {
      print('❌ Exception khi duyệt: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isSearching) {
          setState(() {
            isSearching = false;
            searchController.clear();
            fetchAppointments();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          title: isSearching
              ? TextField(
            controller: searchController,
            autofocus: true,
            onChanged: (value) => fetchAppointments(query: value),
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'Tìm thú cưng',
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
            ),
          )
              : const Text(
            'Lịch hẹn',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    fetchAppointments();
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (isLoading) const LinearProgressIndicator(),
            Expanded(
              child: appointments.isEmpty
                  ? const Center(child: Text('Chưa có lịch hẹn nào.', style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    final status = appt['Status'] ?? 'Chưa có trạng thái';
                    final userName = appt['user']?['FullName'] ?? 'Không có tên khách hàng';
                    final staffName = appt['staff']?['FullName'] ?? appt['staff']?['name'] ?? 'Không có nhân viên phụ trách';
                    final petName = appt['pet']?['Name'] ?? 'Không có tên thú cưng';

                    // Format ngày: chỉ lấy phần ngày (YYYY-MM-DD)
                    String rawDate = appt['AppointmentDate'] ?? '';
                    String dateOnly = rawDate.split('T').first;

                    final appointmentTime = appt['AppointmentTime'] ?? '';
                    final serviceNames = (appt['services'] as List?)?.map((s) => s['ServiceName']).join(', ') ?? 'Không có tên dịch vụ';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AppointmentDetailPage(appointment: appt)),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.pets, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    petName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Dòng ngày giờ riêng
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  dateOnly,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(width: 20),
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  appointmentTime,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Text('👤 Khách hàng: $userName'),
                            Text('👨‍📫 Nhân viên: $staffName'),
                            Text('🛠️ Dịch vụ: $serviceNames'),
                            if (appt['Reason'] != null && appt['Reason'].toString().isNotEmpty)
                              Text('📜 Ghi chú: ${appt['Reason']}'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildStatusTag(status),
                                TextButton(
                                  onPressed: () => deleteAppointment(appt['AppointmentID']),
                                  style: TextButton.styleFrom(
                                    foregroundColor: role == 'staff' ? Colors.orange : Colors.red,
                                  ),
                                  child: Text(role == 'staff' ? 'Hủy lịch hẹn' : 'Xóa lịch hẹn'),
                                ),
                              ],
                            ),
                            if (role == 'staff')
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: statusActions(status, appt['AppointmentID'], appt['services'] ?? []),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
        floatingActionButton: role != 'staff'
            ? FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AppointmentScreen()),
            );
            if (result == true) {
              await fetchAppointments();
            }
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class SelectMedicineDialog extends StatefulWidget {
  final List<dynamic> medicines;
  const SelectMedicineDialog(this.medicines);

  @override
  State<SelectMedicineDialog> createState() => _SelectMedicineDialogState();
}

class _SelectMedicineDialogState extends State<SelectMedicineDialog> {
  final Set<dynamic> selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Chọn thuốc (tùy chọn)"),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: widget.medicines.length,
          itemBuilder: (_, i) {
            final med = widget.medicines[i];
            final isSelected = selected.any((e) => e['MedicationID'] == med['MedicationID']);
            return CheckboxListTile(
              title: Text(med['Name']),
              subtitle: Text("Giá: ${med['Price']} VNĐ"),
              value: isSelected,
              onChanged: (_) {
                setState(() {
                  if (isSelected) {
                    selected.removeWhere((e) => e['MedicationID'] == med['MedicationID']);
                  } else {
                    selected.add(med);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected.toList()),
          child: const Text("Xác nhận"),
        ),
      ],
    );
  }
}
