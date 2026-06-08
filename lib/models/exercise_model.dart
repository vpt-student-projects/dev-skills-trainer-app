class ExerciseModel {
  final int exerciseId;
  final int lessonId;
  final String taskDescription;
  final String rightAnswer;
  final List<AnswerOption> options;

  ExerciseModel({
    required this.exerciseId,
    required this.lessonId,
    required this.taskDescription,
    required this.rightAnswer,
    required this.options,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> answersJson = json['answers'] ?? [];
    final List<AnswerOption> options = answersJson
        .map((a) => AnswerOption(
              answerId: a['answerId'] ?? a['id'] ?? 0,
              text: a['answer'].toString(),
            ))
        .toList();

    return ExerciseModel(
      exerciseId: json['exerciseId'],
      lessonId: json['lessonId'],
      taskDescription: json['taskDescription'],
      rightAnswer: json['rightAnswer'] ?? '',
      options: options,
    );
  }
}

class AnswerOption {
  final int answerId;
  final String text;

  AnswerOption({required this.answerId, required this.text});
}