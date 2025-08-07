// lib/data/providers/patient_provider.dart
import 'package:ayur_care_app/core/utils/shared_pref.dart';
import 'package:ayur_care_app/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:ayur_care_app/data/models/patient_model.dart';
import 'package:ayur_care_app/data/models/branch_model.dart';
import 'package:ayur_care_app/data/models/treatment_model.dart';

class PatientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize provider with token from SharedPrefs
  Future<void> initialize() async {
    final token = await SharedPrefs.getToken();
    if (token != null && token.isNotEmpty) {
      _apiService.setToken(token);
    }
  }

  // Fetch patient list
  Future<void> fetchPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patients = await _apiService.getPatientList();
    } catch (e) {
      _errorMessage = e.toString();
      _patients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new patient
  Future<bool> registerPatient({
    required String name,
    required String executive,
    required String payment,
    required String phone,
    required String address,
    required double totalAmount,
    required double discountAmount,
    required double advanceAmount,
    required double balanceAmount,
    required String dateAndTime,
    required String branch,
    required List<String> maleTreatments,
    required List<String> femaleTreatments,
    required List<String> treatments,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.registerPatient(
        name: name,
        executive: executive,
        payment: payment,
        phone: phone,
        address: address,
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        advanceAmount: advanceAmount,
        balanceAmount: balanceAmount,
        dateAndTime: dateAndTime,
        branch: branch,
        maleTreatments: maleTreatments,
        femaleTreatments: femaleTreatments,
        treatments: treatments,
      );
      await fetchPatients(); // Refresh patient list after registration
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch branch list
  Future<List<Branch>> fetchBranches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final branches = await _apiService.getBranchList();
      return branches;
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch treatment list
  Future<List<Treatment>> fetchTreatments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final treatments = await _apiService.getTreatmentList();
      return treatments;
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
