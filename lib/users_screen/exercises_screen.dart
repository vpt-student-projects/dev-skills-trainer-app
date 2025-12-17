// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vpt_learn/models/exercise_model.dart';
import 'package:vpt_learn/services/lesson_service.dart';

class ExercisesScreen extends StatefulWidget {
  final int lessonId;

  const ExercisesScreen({super.key, required this.lessonId});

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
   List<ExerciseModel> _exercises = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isLoading = true;
  String? _errorMessage;

  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
       var exercises = await LessonService().fetchExercises(widget.lessonId);
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки упражнений';
        _isLoading = false;
      });
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final currentExercise = _exercises[_currentIndex];
    if (_selectedAnswer!.trim().toLowerCase() ==
        currentExercise.rightAnswer.trim().toLowerCase()) {
      _score++;
    }

    if (_currentIndex + 1 < _exercises.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _score = 0;
      _currentIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_exercises.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Задания не найдены')),
      );
    }

    if (_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text('Результат теста')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Вы набрали $_score из ${_exercises.length}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _restartQuiz,
                child: const Text('Пройти заново'),
              ),
            ],
          ),
        ),
      );
    }

    final currentExercise = _exercises[_currentIndex];


    return Scaffold(
      appBar: AppBar(
        title: Text('Вопрос ${_currentIndex + 1} из ${_exercises.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentExercise.taskDescription,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ...currentExercise.options.map(
              (option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() { 
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _submitAnswer,
                child: Text(
                _currentIndex + 1 == _exercises.length ? 'Завершить' : 'Далее',

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Exercise {
  final String taskDescription;
  final String rightAnswer;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;

  Exercise({
    required this.taskDescription,
    required this.rightAnswer,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
  });
}
