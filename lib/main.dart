import 'package:examen_dev_mobile_diop_momy_l3gl_2025_2026/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // On initialise le provider principal (qui initialise le StorageService)
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    // 3. On enveloppe l'app avec tous les Providers (MultiProvider)
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const SunuTaskApp(),
    ),
  );
}

class SunuTaskApp extends StatelessWidget {
  const SunuTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunuTask',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Utilise ton thème clair
      darkTheme: AppTheme.darkTheme, // Utilise ton thème sombre
      home: const SplashScreen(), // Démarre sur le Splash
      // On définit les routes pour la navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
       // '/home': (context) => const HomeScreen(),
      },
    );
  }
}