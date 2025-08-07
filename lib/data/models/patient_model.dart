// lib/data/models/patient_model.dart
import 'package:ayur_care_app/data/models/patientdetails_model';

import 'package:ayur_care_app/data/models/branch_model.dart';

class Patient {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String payment;
  final double totalAmount;
  final double discountAmount;
  final double advanceAmount;
  final double balanceAmount;
  final String? dateAndTime;
  final Branch? branch; // branch can be null
  final List<PatientDetail> patientDetails;
  final String user; // user may be string or object, but we store its toString()

  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    required this.totalAmount,
    required this.discountAmount,
    required this.advanceAmount,
    required this.balanceAmount,
    required this.dateAndTime,
    required this.branch,
    required this.patientDetails,
    required this.user,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // safe parse helpers
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        return double.tryParse(v) ?? 0.0;
      }
      return 0.0;
    }

    // patientdetails_set could be null or not a list
    final pdRaw = json['patientdetails_set'];
    final List<PatientDetail> details = [];
    if (pdRaw != null && pdRaw is List) {
      for (final e in pdRaw) {
        try {
          if (e != null && e is Map<String, dynamic>) {
            details.add(PatientDetail.fromJson(e));
          } else if (e != null && e is Map) {
            // map with dynamic typing
            details.add(PatientDetail.fromJson(Map<String, dynamic>.from(e)));
          }
        } catch (_) {
          // skip any malformed item, but continue parsing others
        }
      }
    }

    // branch may be null or Map
    Branch? branchObj;
    final branchRaw = json['branch'];
    if (branchRaw != null && branchRaw is Map<String, dynamic>) {
      branchObj = Branch.fromJson(branchRaw);
    } else if (branchRaw != null && branchRaw is Map) {
      branchObj = Branch.fromJson(Map<String, dynamic>.from(branchRaw));
    } else {
      branchObj = null;
    }

    // user could be string or a nested object (e.g. user.name)
    String userStr = '';
    final userRaw = json['user'];
    if (userRaw == null) {
      userStr = '';
    } else if (userRaw is String) {
      userStr = userRaw;
    } else if (userRaw is Map) {
      // try common fields
      userStr = (userRaw['name'] ?? userRaw['username'] ?? userRaw['id'])?.toString() ?? userRaw.toString();
    } else {
      userStr = userRaw.toString();
    }

    return Patient(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      payment: (json['payment'] ?? '').toString(),
      totalAmount: _toDouble(json['total_amount']),
      discountAmount: _toDouble(json['discount_amount']),
      advanceAmount: _toDouble(json['advance_amount']),
      balanceAmount: _toDouble(json['balance_amount']),
      dateAndTime: (json['date_and_time'] ?? json['date_nd_time'] ?? json['date'] ?? json['dateAndTime'])?.toString(),
      branch: branchObj,
      patientDetails: details,
      user: userStr,
    );
  }
}
