import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/static_data.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/landing/landing_screen.dart';
import 'features/map/nearby_screen.dart';
import 'features/order/cart_screen.dart';
import 'features/saved/favorites_screen.dart';
import 'features/shop/shop_screen.dart';
import 'services/product_service.dart';

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
        '/saved': (context) => const FavoritesScreen(),
        '/cart': (context) => const CartScreen(),
        '/nearby': (context) => const NearbyScreen(),
        '/shop': (context) => ShopScreen(
              products: StaticData.products,
              onFavoriteToggle: (product) {
                ProductService.toggleFavorite(product.id);
              },
              onAddToCart: (product) {
                product.cartQty++;
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
                ProductService.toggleFavorite(product.id);
              },
              onAddToCart: (product) {
                product.cartQty++;
              },
            ),
      },
    );
  }
}