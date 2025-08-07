// lib/data/services/api_service.dart
import 'dart:convert';
import 'package:ayur_care_app/core/constants/app_constants.dart';
import 'package:ayur_care_app/data/models/branch_model.dart';
import 'package:ayur_care_app/data/models/patient_model.dart';
import 'package:ayur_care_app/data/models/treatment_model.dart';
import 'package:ayur_care_app/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/x-www-form-urlencoded'};
    if (_token != null && _token!.isNotEmpty) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Map<String, String> get _jsonHeaders {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse(AppConstants.loginUrl);
    final response = await http.post(uri, headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: {'username': username, 'password': password});
    debugPrint('login status: ${response.statusCode}');
    debugPrint('login body: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
      _token = data['token'];
      return {
        'token': data['token'],
        if (data['user_details'] != null) 'user': User.fromJson(data['user_details']),
      };
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<List<Patient>> getPatientList() async {
    final uri = Uri.parse('$baseUrl/PatientList');
    debugPrint('ApiService.getPatientList() token: $_token');
    final response = await http.get(uri, headers: _jsonHeaders);
    debugPrint('GET $uri -> status: ${response.statusCode}');
    debugPrint('GET $uri -> body: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
      final dynamic patientsJson = data['patient'] ?? data['patients'] ?? data['data'] ?? data;
      if (patientsJson is List) {
        return patientsJson.map<Patient>((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Unexpected patients payload type: ${patientsJson.runtimeType}');
      }
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch patients (status: ${response.statusCode})');
    }
  }

  Future<List<Branch>> getBranchList() async {
    final uri = Uri.parse('$baseUrl/BranchList');
    final response = await http.get(uri, headers: _jsonHeaders);
    debugPrint('GET $uri -> ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
      final dynamic branchJson = data['branch'] ?? data['branches'] ?? data['data'] ?? data;
      if (branchJson is List) {
        return branchJson.map<Branch>((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Unexpected branch payload type: ${branchJson.runtimeType}');
      }
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch branches');
    }
  }

  Future<List<Treatment>> getTreatmentList() async {
    final uri = Uri.parse('$baseUrl/TreatmentList');
    final response = await http.get(uri, headers: _jsonHeaders);
    debugPrint('GET $uri -> ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
      final dynamic treatmentJson = data['treatment'] ?? data['treatments'] ?? data['data'] ?? data;
      if (treatmentJson is List) {
        return treatmentJson.map<Treatment>((e) => Treatment.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Unexpected treatments payload type: ${treatmentJson.runtimeType}');
      }
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch treatments');
    }
  }

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
    required String branch, // branch id
    required List<String> maleTreatments, // repeated ids allowed
    required List<String> femaleTreatments,
    required List<String> treatments,
  }) async {
    final maleCsv = maleTreatments.join(',');
    final femaleCsv = femaleTreatments.join(',');
    final treatmentsCsv = treatments.join(',');

    final body = <String, String>{
      'name': name,
      'executive': executive,
      'excecutive': executive, // defensive duplicate (we keep to be safe)
      'payment': payment,
      'phone': phone,
      'address': address,
      'total_amount': totalAmount.toString(),
      'discount_amount': discountAmount.toString(),
      'advance_amount': advanceAmount.toString(),
      'balance_amount': balanceAmount.toString(),
      'date_and_time': dateAndTime,
      'date_nd_time': dateAndTime,
      'id': '',
      'male': maleCsv,
      'female': femaleCsv,
      'branch': branch,
      'treatments': treatmentsCsv,
    };

    final uri = Uri.parse('$baseUrl/PatientUpdate');
    debugPrint('POST $uri body: $body');

    final response = await http.post(uri, headers: _headers, body: body);

    debugPrint('POST $uri -> status: ${response.statusCode}');
    debugPrint('POST $uri -> body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && (data['status'] == true || data['status'] == 'true')) {
        return;
      } else {
        final message = data is Map ? (data['message'] ?? 'Unknown') : 'Unknown';
        throw Exception(message);
      }
    } else {
      throw Exception('Failed to register patient (status: ${response.statusCode})');
    }
  }
}
