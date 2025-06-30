
import 'package:flutter/material.dart';

import '../Page/PageScreen.dart';
import 'AddPetScreen.dart';


class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thú cưng", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PageScreen()),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildPetCard(
            context: context,
            name: "MeoMeo",
            weight: "3kg",
            genderIcon: Icons.male,
            color: "Xám",
            status: "Sốt nhẹ",
          ),
          const SizedBox(height: 12),
          _buildPetCard(
            context: context,
            name: "Dưa Hấu",
            weight: "3.5kg",
            genderIcon: Icons.female,
            color: "Vàng",
            status: "Tiêm Vaccine",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddPetScreen()),
          );
        },
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildPetCard({
    required BuildContext context,
    required String name,
    required String weight,
    required IconData genderIcon,
    required String color,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("$name - $weight", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(genderIcon, size: 18, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildTag("Màu lông: $color", Colors.orange),
                    _buildTag("Tình trạng: $status", Colors.deepOrange),
                  ],
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => PetSecondScreen()),
              // );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: const Text("Xem"),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}
