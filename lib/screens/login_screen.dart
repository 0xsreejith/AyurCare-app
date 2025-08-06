import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ayur_care_app/core/constants/app_constants.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          Container(
  height: MediaQuery.of(context).size.height * 0.3,
  width: double.infinity,
  child: Stack(
    fit: StackFit.expand,
    children: [
      // Background Image
      Image.asset(
        'assets/background.jpg',
        fit: BoxFit.cover,
      ),

      // Blur effect
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          color: Colors.black.withOpacity(0), 
        ),
      ),

      // Centered Logo
      Center(
        child: Image.asset(
          'assets/logo.png',
          width: 80,
          height: 80,
        ),
      ),
    ],
  ),
),
          // White Form Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),

                    /// 👇 Login Heading with Google Fonts (Poppins)
                    Text(
                      'Login Or Register To Book\nYour Appointments',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4,
                        textStyle: TextStyle(
                          letterSpacing: 0,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Email Label
                    Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Email Field
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password Label
                    Text(
                      'Password',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Terms and Conditions
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'By creating or logging into an account you are agreeing with our ',
                            ),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
