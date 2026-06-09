class LessonModel {
  final int lessonId;
  final int courseId;
  final String title;
  final String content;
  final int orderIndex;
  final String type;

  LessonModel({
    required this.lessonId,
    required this.courseId,
    required this.title,
    required this.content,
    required this.orderIndex,
    required this.type
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lessonId'],
      courseId: json['courseId'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      orderIndex: json['orderIndex'],
    );
  }
}
