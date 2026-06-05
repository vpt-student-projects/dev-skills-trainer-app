class LanguageModel {
  final int id;
  final String name;
  final String description;
  final String features;
  final String example;
  final DateTime? createdAt;

  LanguageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.features,
    required this.example,
    this.createdAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      features: json['features'] ?? '',
      example: json['example'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'features': features,
      'example': example,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}