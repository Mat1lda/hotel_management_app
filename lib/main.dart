import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screen/splash_screen.dart';
import 'screen/main_screen.dart';
import 'screen/register_screen.dart';
import 'screen/search_screen.dart';
import 'utility/app_colors.dart';
import 'screen/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/search': (context) => const SearchScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

