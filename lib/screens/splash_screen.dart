import 'package:ayur_care_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/bg.png',
            fit: BoxFit.cover,
          ),

          // Color overlay
          Container(
            color: const Color(0x99021400),
          ),

          // Logo
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
