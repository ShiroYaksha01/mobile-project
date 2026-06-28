import 'package:flutter/material.dart';

class OrderConfirmScreen extends StatelessWidget {
  const OrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            const ListTile(title: Text('Subtotal'), trailing: Text('\$50.00')),
            const ListTile(title: Text('Shipping'), trailing: Text('\$5.00')),
            const ListTile(title: Text('Grand Total'), trailing: Text('\$55.00', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: const TextField(
                    decoration: InputDecoration(labelText: 'Promo Code', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Validate promo code
                  },
                  child: const Text('Validate'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Place order logic
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Place Order', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
