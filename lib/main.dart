import 'package:flutter/material.dart';
import 'package:formeasy/screens/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:formeasy/providers/form_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('forms');
  await Hive.openBox('entries');

  runApp(const MyApp());
}
// lib/main.dart

// Our new vibrant and professional color palette
const Color primaryColor = Color(0xFF333333); // A deep charcoal for text
const Color accentColor = Color(0xFFFF6D00); // A vibrant, confident orange
const Color backgroundColor = Color(0xFFF5F7F9); // A clean, slightly cool off-white

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FormEasy',
        theme: ThemeData(
          primaryColor: primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentColor,
            primary: primaryColor,
            secondary: accentColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: AppBarTheme(
            // The AppBar is almost transparent to allow the blur effect
            backgroundColor: backgroundColor.withOpacity(0.85),
            foregroundColor: primaryColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: primaryColor),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.white,
            filled: true,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}