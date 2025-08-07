// lib/data/models/branch_model.dart
class Branch {
  final int id;
  final String name;
  final int patientsCount;
  final String location;
  final String phone;
  final String mail;
  final String address;
  final String gst;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.patientsCount,
    required this.location,
    required this.phone,
    required this.mail,
    required this.address,
    required this.gst,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      patientsCount: json['patients_count'] is int ? json['patients_count'] : int.tryParse('${json['patients_count']}') ?? 0,
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      mail: json['mail'] ?? '',
      address: json['address'] ?? '',
      gst: json['gst'] ?? '',
      isActive: (json['is_active'] == true || json['is_active'] == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'patients_count': patientsCount,
        'location': location,
        'phone': phone,
        'mail': mail,
        'address': address,
        'gst': gst,
        'is_active': isActive,
      };

  @override
  String toString() => name;
}
