// lib/data/models/treatment_model.dart
import 'branch_model.dart';

class Treatment {
  final int id;
  final String name;
  final String duration;
  final double price;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Branch> branches;

  Treatment({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.branches = const [],
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic p) {
      if (p == null) return 0.0;
      if (p is double) return p;
      if (p is int) return p.toDouble();
      final s = p.toString();
      return double.tryParse(s.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;
    }

    DateTime? tryParseDate(dynamic s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s.toString());
      } catch (_) {
        return null;
      }
    }

    List<Branch> parsedBranches = [];
    if (json['branches'] is List) {
      parsedBranches = (json['branches'] as List).map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
    }

    return Treatment(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      price: parsePrice(json['price']),
      isActive: (json['is_active'] == true || json['is_active'] == 'true'),
      createdAt: tryParseDate(json['created_at']),
      updatedAt: tryParseDate(json['updated_at']),
      branches: parsedBranches,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'duration': duration,
        'price': price,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'branches': branches.map((b) => b.toJson()).toList(),
      };

  @override
  String toString() => '$name (₹${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)})';
}
