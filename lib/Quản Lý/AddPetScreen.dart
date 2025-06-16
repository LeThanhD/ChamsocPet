import 'package:chamsocpet/Page/PageScreen.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/PetScreen.dart';
import 'package:flutter/material.dart';

class AddPetScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController healthController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PageScreen()),
                        );
                      },
                    ),

                    const Expanded(
                      child: Center(
                        child: Text(
                          'Thêm thú cưng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // space to balance back icon
                  ],
                ),

                const SizedBox(height: 20),

                _buildTextField('Tên thú cưng', nameController),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField('Giới tính', ['Đực', 'Cái']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField('Màu sắc', colorController),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _buildDropdownField('Loài', ['Chó', 'Mèo']),
                const SizedBox(height: 12),
                _buildDropdownField('Giống', ['Poodle', 'Alaska', 'Ta']),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Ngày sinh', dobController),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField('Cân nặng', weightController),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _buildTextField('Tình trạng sức khỏe', healthController),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PetScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    String? selectedValue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label),
          value: selectedValue,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            // implement using stateful logic if needed
          },
        ),
      ),
    );
  }
}
