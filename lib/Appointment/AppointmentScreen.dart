import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import '../Pet/AddPetScreen.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController noteController = TextEditingController();
  String? userId;
  String? selectedTime;
  String? selectedStaffID;
  DateTime? selectedDate;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  List<Map<String, String>> allBookedSlots = [];
  List<String> selectedPetIDs = [];
  Map<String, List<dynamic>> filteredServicesBySpecies = {};
  List<String> bookedTimes = [];
  Map<String, List<dynamic>> servicesBySpecies = {};
  Set<String> selectedSpeciesList = {};
  List<String> selectedServiceIDs = [];
  List<String> availableTimes = [];
  List<dynamic> petList = [];
  List<dynamic> serviceList = [];
  List<dynamic> staffList = [];

  @override
  void initState() {
    super.initState();
    initUserData();
  }

  Future<void> initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    if (userId == null) return;
    await fetchPets();
    await fetchStaff();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchPets() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/pets/user/$userId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> pets = decoded is List ? decoded : decoded['data'] ??
          [];
      setState(() {
        petList = pets;
      });
    }
  }

  void filterServices(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        filteredServicesBySpecies = Map.from(servicesBySpecies);
      });
      return;
    }

    final keyword = value.trim().toLowerCase();
    final Map<String, List<dynamic>> filtered = {};

    servicesBySpecies.forEach((species, services) {
      final matched = services.where((s) =>
          (s['ServiceName'] ?? '').toLowerCase().contains(keyword)).toList();

      if (matched.isNotEmpty) {
        filtered[species] = matched;
      }
    });

    setState(() {
      filteredServicesBySpecies = filtered;
    });
  }


  Future<void> fetchAllBookedSlots(String staffId) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/appointments/staff/booked/slots?staff_id=$staffId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      setState(() {
        allBookedSlots = data.map<Map<String, String>>((item) => {
          'date': item['AppointmentDate'].toString().split('T')[0],
          'time': item['AppointmentTime'].toString().substring(0, 5),
        }).toList();
      });
    }
  }

  Future<void> fetchStaff() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/users/staff?role=staff'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'] ?? [];
      setState(() {
        staffList = data;
        if (data.isNotEmpty) {
          selectedStaffID = data[0]['UserID']?.toString();
        }
      });
    }
  }


  Future<void> fetchAvailableTimes(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse(
          'http://192.168.0.108:8000/api/appointments/check-all?date=$dateStr&staff_id=$selectedStaffID'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<String> allSlots = [
        "08:00", "09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00"
      ];
      final List<String> booked = List<String>.from(decoded['booked_times'] ?? []);

      setState(() {
        bookedTimes = booked; // ✅ gán danh sách giờ bị trùng
        availableTimes = allSlots.where((time) => !booked.contains(time)).toList();
        if (!availableTimes.contains(selectedTime)) selectedTime = null;
      });
    }
  }



  // Kiểm tra lịch hẹn của nhân viên trước khi tạo mới
  Future<bool> checkStaffAvailability() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(
          'http://192.168.0.108:8000/api/appointments/check-staff-availability?staff_id=$selectedStaffID&date=${selectedDate!
              .toIso8601String().split(
              'T')[0]}&time=$selectedTime&user_id=$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['available']; // Trả về true nếu nhân viên còn thời gian trống
    } else {
      return false; // Nếu có lỗi hoặc không thể kiểm tra, giả định là không trống
    }
  }

  Future<void> fetchServicesBySpecies() async {
    Map<String, List<dynamic>> tempMap = {}; // Tạm lưu kết quả

    for (String species in selectedSpeciesList) {
      final response = await http.get(
        Uri.parse('http://192.168.0.108:8000/api/appointments/services/by-species?species=$species'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> services = decoded['data'];
        tempMap[species] = services;
      }
    }

    setState(() {
      servicesBySpecies = tempMap;
      selectedServiceIDs = []; // Reset khi đổi thú cưng
      filteredServicesBySpecies = Map.from(tempMap); // <- thêm dòng này
    });
  }


  Future<void> submitAppointment() async {
    if (selectedPetIDs.isEmpty || selectedServiceIDs.isEmpty ||
        selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đầy đủ thông tin")),
      );
      return;
    }

    // Kiểm tra xem nhân viên có sẵn lịch hẹn trong thời gian đã chọn không
    final isAvailable = await checkStaffAvailability();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Nhân viên đã có lịch hẹn trong thời gian này")),
      );
      return;
    }

    final token = await getToken();
    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập lại")),
      );
      return;
    }

    List<Map<String, dynamic>> createdAppointments = [
    ]; // Mảng để lưu danh sách các cuộc hẹn đã tạo

    for (var petId in selectedPetIDs) {
      final response = await http.post(
        Uri.parse('http://192.168.0.108:8000/api/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'UserID': userId,
          'PetID': [petId], // Tạo một lịch hẹn cho mỗi thú cưng
          'ServiceIDs': selectedServiceIDs,
          'AppointmentDate': selectedDate!.toIso8601String().split('T')[0],
          'AppointmentTime': '$selectedTime:00',
          'Reason': noteController.text
              .trim()
              .isNotEmpty ? noteController.text.trim() : 'Không có ghi chú',
          'Status': 'Chưa duyệt', // Mặc định là "Chưa duyệt"
          'StaffID': selectedStaffID,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> createdAppointment = jsonDecode(
            response.body);
        createdAppointments.add(createdAppointment);
      } else {
        // Lấy thông báo lỗi từ response body
        final errorMessage = jsonDecode(response.body)['message'] ??
            'Đã có lỗi xảy ra, vui lòng thử lại';

        // Hiển thị thông báo lỗi bằng SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return;
      }
    }

    // Nếu tạo thành công các lịch hẹn
    if (createdAppointments.isNotEmpty) {
      if (!mounted) return;
      Navigator.pop(
          context, true); // Điều hướng về màn hình trước nếu tạo thành công
    }
  }


  Widget _buildPetSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Chọn thú cưng",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPetScreen()),
                );
                if (result == 'added') {
                  await fetchPets(); // Tải lại danh sách thú cưng
                }
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text("Thêm"),
              style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (petList.isEmpty)
          const Text("⚠️ Bạn chưa có thú cưng nào!", style: TextStyle(color: Colors.red)),
        ...petList.map((pet) {
          return CheckboxListTile(
            title: Text(pet['Name'] ?? 'Không tên'),
            value: selectedPetIDs.contains(pet['PetID']?.toString()),
              onChanged: (bool? selected) {
                final petID = pet['PetID']?.toString() ?? '';
                final species = pet['Species']?.toString() ?? '';

                setState(() {
                  if (selected == true) {
                    selectedPetIDs.add(petID);
                    selectedSpeciesList.add(species);
                  } else {
                    selectedPetIDs.remove(petID);

                    // ⚠️ Chỉ xóa species nếu không còn thú cưng nào khác có cùng species
                    final remainingSpecies = petList.where((p) =>
                    selectedPetIDs.contains(p['PetID'].toString()) &&
                        p['Species'] == species
                    );

                    if (remainingSpecies.isEmpty) {
                      selectedSpeciesList.remove(species);
                    }
                  }

                  if (selectedPetIDs.isEmpty) {
                    serviceList = [];
                    selectedServiceIDs = [];
                    selectedSpeciesList.clear();
                  }

                  fetchServicesBySpecies(); // Cập nhật dịch vụ theo danh sách species mới
                });
              }
          );
        }).toList(),
      ],
    );
  }


  Widget _buildDropdown(
      String label,
      String? value,
      List<DropdownMenuItem<String>> items,
      void Function(String?)? onChanged, {
        InputDecoration? decoration,
      }) {
    final currentValueExists = value != null &&
        items.any((item) => item.value == value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: currentValueExists ? value : null,
        onChanged: onChanged,
        decoration: decoration ?? InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2E8FF), Color(0xFFD2F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 40, left: 16, right: 16, bottom: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0D9F2), Color(0xFFB6F5FB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Ink(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5DBF5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Đặt lịch hẹn',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 40), // Placeholder
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildPetSelection(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: selectedPetIDs.isEmpty
                            ? const Text("⚠️ Vui lòng chọn thú cưng trước", style: TextStyle(color: Colors.red))
                            : servicesBySpecies.isEmpty
                            ? const Text("⚠️ Không có dịch vụ nào phù hợp với loài thú cưng đã chọn", style: TextStyle(color: Colors.red))
                            : DefaultTabController(
                          length: filteredServicesBySpecies.length,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Chọn dịch vụ",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                    icon: Icon(isSearching ? Icons.close : Icons.search),
                                    onPressed: () {
                                      setState(() {
                                        isSearching = !isSearching;
                                        if (!isSearching) {
                                          searchController.clear();
                                          filteredServicesBySpecies = Map.from(servicesBySpecies);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (isSearching)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (value) => filterServices(value),
                                    decoration: InputDecoration(
                                      hintText: 'Nhập tên dịch vụ...',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              if (filteredServicesBySpecies.isNotEmpty) ...[
                                TabBar(
                                  isScrollable: true,
                                  labelColor: Colors.deepPurple,
                                  unselectedLabelColor: Colors.black54,
                                  indicatorColor: Colors.deepPurple,
                                  tabs: filteredServicesBySpecies.keys
                                      .map((species) => Tab(text: species))
                                      .toList(),
                                ),
                                SizedBox(
                                  height: 250,
                                  child: TabBarView(
                                    children: filteredServicesBySpecies.keys.map((species) {
                                      final serviceList = filteredServicesBySpecies[species]!;

                                      return serviceList.isEmpty
                                          ? const Center(child: Text("⚠️ Không có dịch vụ nào phù hợp"))
                                          : ListView.builder(
                                        itemCount: serviceList.length,
                                        itemBuilder: (context, index) {
                                          final service = serviceList[index];
                                          final id = service['ServiceID'].toString();
                                          final name = service['ServiceName'];
                                          final isSelected = selectedServiceIDs.contains(id);

                                          return CheckboxListTile(
                                            title: Text(name),
                                            value: isSelected,
                                            onChanged: (selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  selectedServiceIDs.add(id);
                                                } else {
                                                  selectedServiceIDs.remove(id);
                                                }
                                              });
                                            },
                                            activeColor: Colors.deepPurple,
                                            controlAffinity: ListTileControlAffinity.leading,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ] else
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text("⚠️ Không có loài thú cưng nào được hỗ trợ dịch vụ", style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdown(
                              'Nhân viên (tuỳ chọn)',
                              selectedStaffID,
                              staffList
                                  .map((s) => DropdownMenuItem<String>(
                                value: s['UserID']?.toString(),
                                child: Text(s['FullName']),
                              ))
                                  .toList(),
                                  (value) async {
                                setState(() {
                                  selectedStaffID = value;
                                  allBookedSlots = []; // Reset lịch đã đặt
                                });
                                if (value != null) {
                                  await fetchAllBookedSlots(value); // 🟢 Gọi API lấy lịch đã đặt
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Nhân viên (tuỳ chọn)',
                                hintText: 'Chọn nhân viên...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// ✅ Hiển thị lịch đã đặt cho nhân viên
                            if (allBookedSlots.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🕒 Nhân viên đã có lịch:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: allBookedSlots
                                        .map((slot) => Chip(
                                      label: Text(
                                        "${slot['date']} - ${slot['time']}",
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),

                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: selectedDate != null
                                    ? selectedDate!.toIso8601String().split('T')[0]
                                    : '',
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                  await fetchAvailableTimes(picked);
                                  if (selectedStaffID != null) {
                                    await fetchAllBookedSlots(selectedStaffID!);
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Ngày hẹn',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildDropdown(
                              'Giờ hẹn',
                              selectedTime,
                              availableTimes
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                  .toList(),
                                  (value) => setState(() => selectedTime = value),
                              decoration: InputDecoration(
                                labelText: 'Giờ hẹn',
                                hintText: 'Chọn giờ...',
                                border: OutlineInputBorder( // ✅ viết đúng: Outline chứ không phải OutLine
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Ghi chú (tuỳ chọn)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: submitAppointment,
                      icon: const Icon(
                          Icons.calendar_today, color: Colors.white),
                      label: const Text(
                          'Đặt lịch hẹn', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}