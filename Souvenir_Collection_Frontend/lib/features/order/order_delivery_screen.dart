import 'package:flutter/material.dart';

class OrderDeliveryScreen extends StatelessWidget {
  const OrderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Address Line 1'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'City'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Postal Code'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Delivery Date'),
              subtitle: const Text('Select a date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                // Date picker logic
              },
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Personal Message (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
