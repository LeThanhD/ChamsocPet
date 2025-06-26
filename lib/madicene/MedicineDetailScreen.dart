import 'package:flutter/material.dart';

class MedicineDetailScreen extends StatefulWidget {
  const MedicineDetailScreen({super.key});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreen();
}

class _MedicineDetailScreen extends State<MedicineDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            //   Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => ServicePackageScreen()),
            // );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.grey[400],
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vitamin tổng hợp",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "50.000đ",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                const Text("Liều lượng:", style: TextStyle(fontWeight: FontWeight.bold)),
                const Text("1"),
                const Text("Mô tả dịch vụ:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  "Bổ sung vitamin",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 16),


                // Quantity selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove),
                      color: Colors.orange,
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Add to cart button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  // TODO: Handle add to cart with quantity
                },
                child: const Text("Thêm vào giỏ hàng"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
