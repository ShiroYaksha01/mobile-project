import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/artisan_service.dart';
import 'services/favorites_service.dart';
import 'services/order_service.dart';
import 'services/map_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/products/product_bloc.dart';
import 'blocs/products/product_event.dart';
import 'blocs/artisans/artisan_bloc.dart';
import 'blocs/artisans/artisan_event.dart';
import 'navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SouvenirApp());
}

class SouvenirApp extends StatefulWidget {
  const SouvenirApp({super.key});

  @override
  State<SouvenirApp> createState() => _SouvenirAppState();
}

class _SouvenirAppState extends State<SouvenirApp> {
  late final ApiClient apiClient;
  late final AuthService authService;
  late final ProductService productService;
  late final ArtisanService artisanService;
  late final FavoritesService favoritesService;
  late final OrderService orderService;
  late final MapService mapService;
  late final AuthBloc authBloc;
  late final ProductBloc productBloc;
  late final ArtisanBloc artisanBloc;
  late final AppRouter appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize dependencies
    apiClient = ApiClient();
    authService = AuthService(apiClient);
    productService = ProductService(apiClient);
    artisanService = ArtisanService(apiClient);
    favoritesService = FavoritesService(apiClient);
    orderService = OrderService(apiClient);
    mapService = MapService(apiClient);

    // Initialize blocs
    authBloc = AuthBloc(authService: authService);
    productBloc = ProductBloc(productService: productService);
    artisanBloc = ArtisanBloc(artisanService: artisanService);

    // Initial events
    authBloc.add(AuthCheckRequested());
    productBloc.add(LoadProductsRequested());
    artisanBloc.add(LoadArtisansRequested());

    // Initialize Router
    appRouter = AppRouter(authBloc);
  }

  @override
  void dispose() {
    authBloc.close();
    productBloc.close();
    artisanBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide services and blocs globally at the root
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FavoritesService>.value(value: favoritesService),
        RepositoryProvider<OrderService>.value(value: orderService),
        RepositoryProvider<MapService>.value(value: mapService),
        RepositoryProvider<ProductService>.value(value: productService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ProductBloc>.value(value: productBloc),
          BlocProvider<ArtisanBloc>.value(value: artisanBloc),
        ],
        child: MaterialApp.router(
          title: 'Khmer Souvenirs',
          theme: buildAppTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeMode.system,
          routerConfig: appRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
