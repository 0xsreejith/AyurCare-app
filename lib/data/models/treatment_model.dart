class Treatment {
  final int id;
  final String name;
  final String male;
  final String female;

  Treatment({
    required this.id,
    required this.name,
    required this.male,
    required this.female,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['treatment'] ?? json['id'],
      name: json['treatment_name'] ?? '',
      male: json['male'] ?? '',
      female: json['female'] ?? '',
    );
  }
}