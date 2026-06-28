import 'package:flutter/material.dart';

class OrderReviewScreen extends StatelessWidget {
  const OrderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Review')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: Text('Cart Item ${index + 1}'),
                          subtitle: const Text('\$25.00'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
                                const Text('1'), // Quantity Adjuster
                                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Gift Wrap'),
                                Switch(value: false, onChanged: (val) {}), // Gift wrap toggle
                              ],
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
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Subtotal:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$50.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
