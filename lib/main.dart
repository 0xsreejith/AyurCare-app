import 'package:ayur_care_app/data/services/api_service.dart';
import 'package:ayur_care_app/providers/auth_provider.dart';
import 'package:ayur_care_app/providers/patient_provider.dart';
import 'package:ayur_care_app/providers/register_provider.dart';
import 'package:ayur_care_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final apiService = ApiService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)..loadToken()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AyurCare',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
