import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/products/product_bloc.dart';
import '../blocs/products/product_state.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../services/product_service.dart';
import 'user_shell.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    // Refresh the router when auth state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      
      final path = state.uri.path;
      
      // Define routes that REQUIRE authentication
      final isProtectedRoute = path.startsWith('/cart') || 
                               path.startsWith('/chat') || 
                               path.startsWith('/profile');

      // Define auth-specific routes (login/register)
      final isAuthRoute = path == '/login' || path == '/register';

      // If user is trying to access a protected route and is not logged in
      if (isProtectedRoute && !isAuth) {
        return '/login'; // Redirect to login
      }

      // If user is logged in and tries to access login/register, send them to home
      if (isAuthRoute && isAuth) {
        return '/home';
      }

      // No redirect needed, let them proceed
      return null;
    },
    
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // The StatefulShellRoute handles the Bottom Navigation Bar and persists state across tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return UserShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, productState) {
                      if (productState is ProductLoading) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (productState is ProductError) {
                        return Scaffold(
                          body: Center(child: Text('Error: ${productState.message}')),
                        );
                      } else if (productState is ProductLoaded) {
                        return HomeScreen(
                          products: productState.products,
                          onFavoriteToggle: (p) {
                            ProductService.toggleFavorite(p.id);
                          },
                          onAddToCart: (p) {
                            p.cartQty++;
                          },
                        );
                      }
                      return const Scaffold(
                        body: Center(child: Text('No Products available')),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          
          // Branch 2: Shop
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shop',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Shop Screen (Public)')),
                ),
              ),
            ],
          ),
          
          // Branch 3: Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Map Screen (Public)')),
                ),
              ),
            ],
          ),
          
          // Branch 4: Profile (Protected)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Profile Screen (Protected)'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                          child: const Text('Logout'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      
      // Nested screens that don't need the bottom navigation bar can go out here
      GoRoute(
        path: '/cart',
        builder: (context, state) => const Scaffold(
          appBar: MyAppBar(title: 'Cart'), // We'll implement MyAppBar later
          body: Center(child: Text('Cart Screen (Protected)')),
        ),
      ),
    ],
  );
}

// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Dummy MyAppBar to prevent compilation error if uncommented
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MyAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
