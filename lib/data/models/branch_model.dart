class Branch {
  final int id;
  final String name;
  final String location;
  final String phone;
  final String email;
  final String address;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      phone: json['phone'],
      email: json['mail'],
      address: json['address'],
    );
  }
}