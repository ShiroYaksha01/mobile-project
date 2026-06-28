import 'package:flutter/material.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisan Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Artisan Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.verified, color: Colors.blue), // Verified badge
              ],
            ),
            const SizedBox(height: 8),
            const Text('Master Silversmith (Craft)', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            const Text('Bio: Dedicated to preserving ancient Cambodian silver craftsmanship.'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, color: Colors.orange),
                Text(' 4.9 (120 Ratings)'),
              ],
            ),
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Products List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // Placeholder for products list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.image),
                  title: Text('Artisan Product ${index + 1}'),
                  subtitle: const Text('\$45.00'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
