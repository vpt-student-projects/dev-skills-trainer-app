class CourseModel {
  final int id;
  final String title;
  final String description;
  final double? progress; // nullable

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.progress, // может быть null
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['courseId'],
      title: json['title'],
      description: json['description'],
      progress: json['progress'] != null
          ? (json['progress'] as num).toDouble()
          : null, // nullable
    );
  }
}
