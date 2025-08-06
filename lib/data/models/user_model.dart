class User {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String username;
  final String? branch;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.username,
    this.branch,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? json['username'], 
      phone: json['phone'],
      email: json['mail'],
      username: json['username'],
      branch: json['branch'],
    );
  }
}