import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/static_data.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/landing/landing_screen.dart';
import 'features/shop/shop_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crafted in Cambodia',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => LandingScreen(
              onBeginJourney: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/shop': (context) => ShopScreen(
              products: StaticData.products,
              onFavoriteToggle: (product) {
                // TODO: connect to favorites cubit
              },
              onAddToCart: (product) {
                // TODO: connect to cart cubit
              },
            ),
        '/login': (context) => SignInScreen(
              onSignIn: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
        '/register': (context) => SignUpScreen(
              onSignUp: () {
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