import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/products/product_bloc.dart';
import '../blocs/products/product_state.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/landing/landing_screen.dart';
import '../features/home/home_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/shop/product_detail_screen.dart';
import '../features/shop/artisan_profile_screen.dart';
import '../features/order/order_review_screen.dart';
import '../features/order/order_delivery_screen.dart';
import '../features/order/order_confirm_screen.dart';
import '../features/order/order_history_screen.dart';
import '../features/saved/favorites_screen.dart';
import '../features/order/cart_screen.dart';
import '../features/map/nearby_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/about/about_screen.dart';
import '../features/help/help_screen.dart';

// Person B screens
import '../features/explore/explore_screen.dart';
import '../features/explore/collection_detail_screen.dart';
import '../features/map/map_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/quiz/gift_finder_quiz_screen.dart';
import '../features/promotions/promotions_screen.dart';
import '../features/media/media_screen.dart';

import 'user_shell.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/landing',
    // Refresh the router when auth state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isInitial = authState is AuthInitial;

      final path = state.uri.path;

      // On app startup / refresh — always reset to landing, never restore old URL
      if (isInitial && path != '/landing') {
        return '/landing';
      }

      // Auth routes — login/register only
      final isAuthRoute = path == '/login' || path == '/register';

      // Protect non-public routes
      final isPublicRoute = path == '/landing' ||
                            path == '/login' ||
                            path == '/register';

      // If trying to access protected route without login → redirect to login
      if (!isAuth && !isPublicRoute) {
        return '/login';
      }

      // If logged in and on login/register → go to home (landing is always accessible)
      if (isAuth && isAuthRoute) {
        return '/home';
      }

      // No redirect needed
      return null;
    },

    routes: [
      // ── Public routes ──────────────────────────────────────
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Standalone pages ───────────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),

      // ── Person B: Explore & Discovery routes ──────────────
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/collection/:collectionId',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return CollectionDetailScreen(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/reviews/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ReviewsScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const GiftFinderQuizScreen(),
      ),
      GoRoute(
        path: '/promotions',
        builder: (context, state) => const PromotionsScreen(),
      ),
      GoRoute(
        path: '/media',
        builder: (context, state) => const MediaScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/artisan/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ArtisanProfileScreen(artisanId: id);
        },
      ),
      GoRoute(
        path: '/order/review',
        builder: (context, state) => const OrderReviewScreen(),
      ),
      GoRoute(
        path: '/order/delivery',
        builder: (context, state) => const OrderDeliveryScreen(),
      ),
      GoRoute(
        path: '/order/confirm',
        builder: (context, state) => const OrderConfirmScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),

      // ── Main tabbed shell (requires login) ─────────────────
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
                          body: Center(
                              child: Text('Error: ${productState.message}')),
                        );
                      } else if (productState is ProductLoaded) {
                        return HomeScreen(
                          products: productState.products,
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
                builder: (context, state) {
                  return BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, productState) {
                      if (productState is ProductLoading) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (productState is ProductError) {
                        return Scaffold(
                          body: Center(
                              child: Text('Error: ${productState.message}')),
                        );
                      } else if (productState is ProductLoaded) {
                        final query = state.uri.queryParameters['query'] ?? '';
                        return ShopScreen(
                          products: productState.products,
                          initialQuery: query,
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

          // Branch 3: Saved / Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),

          // Branch 4: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Branch 5: Nearby
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/nearby',
                builder: (context, state) => const NearbyScreen(),
              ),
            ],
          ),
        ],
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
