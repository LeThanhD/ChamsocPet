import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ProductDetailScreen()));

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Combo cắt tỉa, tắm, khám sức khỏe",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "200.000đ",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                const Text("Mô tả dịch vụ:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  "Spa cho thú cưng sử dụng sản phẩm chuyên dụng dành cho chó mèo",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 16),
                Row(
                  children: const [
                    Text("Đánh giá sản phẩm:", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Text("5/5"),
                    Icon(Icons.star, color: Colors.orange),
                  ],
                ),

                const SizedBox(height: 24),

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
