import 'package:flutter/material.dart';

class AppAssets {
  static const String background = 'assets/bg.png';
  static const String logo = 'assets/logo.png';
}

class AppColors {
  static const Color overlayColor = Color(0x99021400); 
  static const Color primaryColor = Color(0xFF006837);
}

class AppConstants {
  static const String baseUrl = 'https://flutter-amr.noviindus.in/api';

  static const String loginUrl = '$baseUrl/Login';
  static const String patientListUrl = '$baseUrl/PatientList';
  static const String patientUpdateUrl = '$baseUrl/PatientUpdate';
  static const String branchListUrl = '$baseUrl/BranchList';
  static const String treatmentListUrl = '$baseUrl/TreatmentList';
}

