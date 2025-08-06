import 'package:ayur_care_app/providers/auth_provider.dart';
import 'package:ayur_care_app/providers/patient_provider.dart';
import 'package:ayur_care_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
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
