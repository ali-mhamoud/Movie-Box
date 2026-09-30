import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_constants.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/tmdb_service.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';

// Generated automatically after running: flutterfire configure
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.loadApiKey();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final tmdbService = TmdbService();
  final databaseService = DatabaseService();

  runApp(
    MultiProvider(
      providers: [
        Provider<TmdbService>.value(value: tmdbService),
        Provider<DatabaseService>.value(value: databaseService),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(context.read<TmdbService>()),
        ),
      ],
      child: const MovieBoxApp(),
    ),
  );
}

class MovieBoxApp extends StatelessWidget {
  const MovieBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieBox',
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
