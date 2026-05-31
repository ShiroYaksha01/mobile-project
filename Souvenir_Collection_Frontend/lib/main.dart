import 'package:flutter/material.dart';

import 'data/static_data.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heritage',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => SignInScreen(
              onSignIn: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/home': (context) => HomeScreen(
              products: StaticData.products,
              onFavoriteToggle: (product) {
                // TODO: connect to favorites cubit
              },
              onAddToCart: (product) {
                // TODO: connect to cart cubit
              },
            ),
      },
    );
  }
}