import 'package:ayur_care_app/data/models/branch_model.dart';
import 'package:ayur_care_app/data/models/treatment_model.dart';

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
  final String? dateAndTime; // Raw datetime string from API
  final Branch branch;
  final List<Treatment> treatments;

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
    this.dateAndTime,
    required this.branch,
    required this.treatments,
  });

  /// Parses JSON data into a Patient object
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      payment: json['payment'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      advanceAmount: (json['advance_amount'] ?? 0).toDouble(),
      balanceAmount: (json['balance_amount'] ?? 0).toDouble(),
      dateAndTime: json['date_nd_time'],
      branch: Branch.fromJson(json['branch']),
      treatments: (json['patientdetails_set'] as List)
          .map((e) => Treatment.fromJson(e))
          .toList(),
    );
  }

  /// Converts raw dateAndTime string into DateTime? for formatted use
  DateTime? get createdAt {
    if (dateAndTime == null) return null;
    try {
      return DateTime.parse(dateAndTime!);
    } catch (_) {
      return null;
    }
  }
}
