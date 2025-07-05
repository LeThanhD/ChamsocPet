import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'AppointmentHistory.dart';
import 'AppointmentScreen.dart';
import 'AppointmentDetailPage.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key, required this.appointmentData});
  final Map<String, dynamic> appointmentData;

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

  Future<void> fetchAppointments({String query = ''}) async {
    setState(() => isLoading = true);
    String url;

    if (role == 'staff') {
      url = 'http://10.24.67.249:8000/api/appointments/every?role=staff';
      if (query.isNotEmpty) url += '&search=$query';
    } else {
      url = 'http://10.24.67.249:8000/api/appointments/all?UserID=$userId';
      if (query.isNotEmpty) url += '&search=$query';
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        setState(() {
          appointments = data
              .cast<Map<String, dynamic>>()
              .where((a) => a['Status'] != 'Kết thúc')
              .toList();
        });
      }
    } catch (e) {
      print('❌ Exception: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> saveToHistory(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList('history_appointments') ?? [];
    current.add(jsonEncode(item));
    await prefs.setStringList('history_appointments', current);
  }

  // Future<void> createNotification(String userId, String title, String message) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://10.24.67.249:8000/api/notifications'),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'user_id': userId,
  //         'title': title,
  //         'message': message,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('✅ Tạo thông báo thành công');
  //     } else {
  //       print('❌ Lỗi tạo thông báo: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (e) {
  //     print('❌ Lỗi ngoại lệ khi tạo thông báo: $e');
  //   }
  // }

  Future<void> deleteAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa lịch hẹn này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://10.24.67.249:8000/api/appointments/$appointmentId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments.removeWhere((a) => a['AppointmentID'] == appointmentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã xóa lịch hẹn')),
        );
      } else if (response.statusCode == 403) {
        final message = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ $message')),
        );
      } else {
        print('❌ Xóa thất bại: ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi khi xóa lịch hẹn: $e');
    }
  }

  Future<List<dynamic>> fetchMedications() async {
    final response = await http.get(
      Uri.parse('http://10.24.67.249:8000/api/medications/in'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    try {
      final appointment = appointments.firstWhere(
            (a) => a['AppointmentID'] == appointmentId,
        orElse: () => {},
      );

      if (appointment.isEmpty) {
        print('❌ Không tìm thấy lịch hẹn với ID: $appointmentId');
        return;
      }

      if (status == 'Đã duyệt') {
        final res = await http.put(
          Uri.parse('http://10.24.67.249:8000/api/appointments/update-status/$appointmentId'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'Status': 'Đã duyệt'}),
        );

        if (res.statusCode == 200) {
          setState(() {
            final index = appointments.indexWhere((a) => a['AppointmentID'] == appointmentId);
            if (index != -1) appointments[index]['Status'] = 'Đã duyệt';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cập nhật trạng thái thành công')),
          );
        } else {
          print('❌ Lỗi duyệt: ${res.body}');
        }

        return;
      }

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

        final detailRes = await http.get(
          Uri.parse('http://10.24.67.249:8000/api/appointments/$appointmentId'),
          headers: {'Accept': 'application/json'},
        );

        if (detailRes.statusCode != 200) {
          print('❌ Không lấy được chi tiết: ${detailRes.body}');
          return;
        }

        final apptDetail = jsonDecode(detailRes.body)['data'];
        double servicePrice = double.tryParse(apptDetail['service']?['Price']?.toString() ?? '0') ?? 0;
        double medicinePrice = 0;
        List<Map<String, dynamic>> medIds = [];

        for (var med in selectedMeds) {
          medicinePrice += double.tryParse(med['Price'].toString()) ?? 0;
          medIds.add({'id': med['MedicationID'], 'quantity': 1});
        }

        // Gửi hóa đơn
        final invoiceRes = await http.post(
          Uri.parse('http://10.24.67.249:8000/api/invoices'),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'appointment_id': appointmentId, 'medicine_ids': medIds}),
        );

        if (!(invoiceRes.statusCode == 200 || invoiceRes.statusCode == 201)) {
          print('❌ Lỗi tạo hóa đơn: ${invoiceRes.body}');
          return;
        }

        print('✅ Tạo hóa đơn thành công');

        // Cập nhật trạng thái
        final updateRes = await http.put(
          Uri.parse('http://10.24.67.249:8000/api/appointments/update-status/$appointmentId'),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'Status': 'Kết thúc'}),
        );

        if (updateRes.statusCode == 200) {
          // Ghi lịch sử
          final historyRes = await http.post(
            Uri.parse('http://10.24.67.249:8000/api/appointment-history'),
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
            body: jsonEncode({
              'AppointmentID': appointmentId,
              'StatusBefore': 'Đã duyệt',
              'StatusAfter': 'Kết thúc',
              'Note': 'Cuộc hẹn đã hoàn tất',
            }),
          );

          if (historyRes.statusCode == 201) {
            print('✅ Lưu lịch sử thành công');
          }

          await saveToHistory(apptDetail);

          setState(() {
            final index = appointments.indexWhere((a) => a['AppointmentID'] == appointmentId);
            if (index != -1) appointments[index]['Status'] = 'Kết thúc';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Đã kết thúc lịch hẹn và tạo hóa đơn thành công")),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentHistoryPage()),
          );
        } else {
          print('❌ Lỗi cập nhật trạng thái: ${updateRes.body}');
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }


  Color getStatusColor(String status) {
    switch (status) {
      case 'Kết thúc':
        return Colors.green;
      case 'Đã duyệt':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget statusActions(String current, String id) {
    final Map<String, List<String>> next = {
      'Chưa duyệt': ['Đã duyệt'],
      'Đã duyệt': ['Kết thúc'],
    };

    return Row(
      children: next[current]?.map((s) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: () => updateStatus(id, s),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(
                  20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(s, style: const TextStyle(color: Colors.white)),
          ),
        );
      }).toList() ?? [],
    );
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
          automaticallyImplyLeading: false, // ⬅️ Ẩn nút trở lại
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
              hintText: 'Tìm thú cưng hoặc dịch vụ...',
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
                  final serviceName = appt['service']?['ServiceName'] ?? 'Không có tên dịch vụ';

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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
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
                                  '$petName (${appt['AppointmentDate']} - ${appt['AppointmentTime']})',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('👤 Khách hàng: $userName'),
                          Text('👨‍📫 Nhân viên: $staffName'),
                          Text('🛠️ Dịch vụ: $serviceName'),
                          if (appt['Reason'] != null && appt['Reason'].toString().isNotEmpty)
                            Text('📜 Ghi chú: ${appt['Reason']}'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: getStatusColor(status)),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (role == 'staff')
                                statusActions(status, appt['AppointmentID'])
                              else
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteAppointment(appt['AppointmentID']),
                                  tooltip: "Xóa lịch hẹn",
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: role == 'staff'
            ? null
            : FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AppointmentScreen()),
            );

            if (result == true) {
              setState(() {
                isLoading = true;
              });

              await fetchAppointments();

              setState(() {
                isLoading = false;
              });
            }
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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