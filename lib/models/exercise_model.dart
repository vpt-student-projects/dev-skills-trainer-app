class ExerciseModel {
  final int exerciseId;
  final int lessonId;
  final String taskDescription;
  final String rightAnswer;
  final List<String> options;

  ExerciseModel({
    required this.exerciseId,
    required this.lessonId,
    required this.taskDescription,
    required this.rightAnswer,
    required this.options,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> answersJson = json['answers'] ?? [];
    final List<String> options = answersJson
        .map((a) => a['answerText'].toString())
        .toList();

    // // Гарантируем, что правильный ответ присутствует
    // if (!options.contains(json['rightAnswer'])) {
    //   options.add(json['rightAnswer']);
    // }

    options.shuffle(); // перемешиваем варианты

    return ExerciseModel(
      exerciseId: json['exerciseId'],
      lessonId: json['lessonId'],
      taskDescription: json['taskDescription'],
      rightAnswer: json['rightAnswer'] ?? '',
      options: options,
    );
  }
}
