import 'dart:convert';
import 'package:ayur_care_app/core/constants/app_constants.dart';
import 'package:ayur_care_app/data/models/patient_model.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

import '../models/branch_model.dart';
import '../models/treatment_model.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  // Login API
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(AppConstants.loginUrl),

      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        _token = data['token'];
        return {
          'user': User.fromJson(data['user_details']),
          'token': data['token'],
        };
      }
      throw Exception(data['message'] ?? 'Login failed');
    } else {
      throw Exception(
        'Failed to login. Status code: ${response.statusCode}, Message: ${response.body}',
      );
    }
  }

  // Get Patient List
  Future<List<Patient>> getPatientList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/PatientList'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        return (data['patient'] as List)
            .map((e) => Patient.fromJson(e))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception('Failed to fetch patients');
  }

  // Register Patient
  Future<void> registerPatient({
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
    final response = await http.post(
      Uri.parse('$baseUrl/PatientUpdate'),
      headers: _headers,
      body: {
        'name': name,
        'excecutive': executive,
        'payment': payment,
        'phone': phone,
        'address': address,
        'total_amount': totalAmount.toString(),
        'discount_amount': discountAmount.toString(),
        'advance_amount': advanceAmount.toString(),
        'balance_amount': balanceAmount.toString(),
        'date_nd_time': dateAndTime,
        'id': '',
        'male': maleTreatments.join(','),
        'female': femaleTreatments.join(','),
        'branch': branch,
        'treatments': treatments.join(','),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!data['status']) {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to register patient');
    }
  }

  // Get Branch List
  Future<List<Branch>> getBranchList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/BranchList'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        return (data['branch'] as List).map((e) => Branch.fromJson(e)).toList();
      }
      throw Exception(data['message']);
    }
    throw Exception('Failed to fetch branches');
  }

  // Get Treatment List
  Future<List<Treatment>> getTreatmentList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/TreatmentList'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        return (data['treatment'] as List)
            .map((e) => Treatment.fromJson(e))
            .toList();
      }
      throw Exception(data['message']);
    }
    throw Exception('Failed to fetch treatments');
  }
}
