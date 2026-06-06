import 'package:flutter/material.dart';
import 'package:vpt_learn/models/exercise_model.dart';
import 'package:vpt_learn/services/lesson_service.dart';
import '../theme.dart';

class ExercisesScreen extends StatefulWidget {
  final int lessonId;

  const ExercisesScreen({super.key, required this.lessonId});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<ExerciseModel> _exercises = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Хранит выбранные ответы: ключ = индекс вопроса, значение = выбранный ответ
  Map<int, String?> _selectedAnswers = {};
  
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      _exercises = await LessonService().fetchExercises(widget.lessonId);
      setState(() {
        _isLoading = false;
        // Инициализируем выбранные ответы как null для всех вопросов
        _selectedAnswers = {for (int i = 0; i < _exercises.length; i++) i: null};
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки упражнений: $e';
        _isLoading = false;
      });
    }
  }

  void _submitAnswers() {
    // Проверяем, что на все вопросы даны ответы
    final hasUnanswered = _selectedAnswers.values.any((answer) => answer == null);
    if (hasUnanswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ответьте на все вопросы!')),
      );
      return;
    }
    
    setState(() {
      _showResults = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      _showResults = false;
      _selectedAnswers = {for (int i = 0; i < _exercises.length; i++) i: null};
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadExercises,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_exercises.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Задания не найдены')),
      );
    }

    // ЭКРАН РЕЗУЛЬТАТОВ
    if (_showResults) {
      return _buildResultsScreen();
    }

    // ЭКРАН ТЕСТИРОВАНИЯ (все вопросы на одном экране)
    return Scaffold(
      appBar: AppBar(
        title: Text('Тест (${_exercises.length} вопросов)'),
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Индикатор прогресса
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Прогресс: ${_selectedAnswers.values.where((a) => a != null).length}/${_exercises.length}',
                    style: const TextStyle(color: AppColors.alternate),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _selectedAnswers.values.where((a) => a != null).length / _exercises.length,
                    backgroundColor: Colors.grey,
                    color: AppColors.completed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Все вопросы
            ...List.generate(_exercises.length, (index) {
              final exercise = _exercises[index];
              return _buildQuestionCard(
                index: index,
                question: exercise.taskDescription,
                options: exercise.options,
                selectedAnswer: _selectedAnswers[index],
                onChanged: (value) {
                  setState(() {
                    _selectedAnswers[index] = value;
                  });
                },
              );
            }),
            
            const SizedBox(height: 24),
            
            // Кнопка отправки
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alternate,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '📤 Отправить ответы',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required int index,
    required String question,
    required List<String> options,
    required String? selectedAnswer,
    required void Function(String?) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.alternate,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...options.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedAnswer,
              onChanged: onChanged,
              activeColor: AppColors.alternate,
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    // Подсчитываем результаты
    int correctCount = 0;
    final List<Map<String, dynamic>> results = [];
    
    for (int i = 0; i < _exercises.length; i++) {
      final exercise = _exercises[i];
      final userAnswer = _selectedAnswers[i];
      final isCorrect = userAnswer == exercise.rightAnswer;
      if (isCorrect) correctCount++;
      
      results.add({
        'index': i + 1,
        'question': exercise.taskDescription,
        'userAnswer': userAnswer ?? '(нет ответа)',
        'correctAnswer': exercise.rightAnswer,
        'isCorrect': isCorrect,
      });
    }
    
    final percent = (correctCount / _exercises.length * 100).round();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты теста'),
        backgroundColor: AppColors.secondary,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Карточка с общей оценкой
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: percent >= 70 
                    ? [Colors.green.shade800, Colors.green.shade600]
                    : percent >= 40
                        ? [Colors.orange.shade800, Colors.orange.shade600]
                        : [Colors.red.shade800, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '$correctCount / ${_exercises.length}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  percent >= 70 ? '✅ Отлично!'
                      : percent >= 40 ? '⚠️ Можно лучше'
                      : '❌ Нужно повторить материал',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Список результатов по каждому вопросу
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: result['isCorrect'] 
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: result['isCorrect'] ? Colors.green : Colors.red,
                      child: Text(
                        '${result['index']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      result['question'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ваш ответ: ${result['userAnswer']}',
                          style: TextStyle(
                            color: result['isCorrect'] ? Colors.green : Colors.red,
                          ),
                        ),
                        if (!result['isCorrect'])
                          Text(
                            'Правильный: ${result['correctAnswer']}',
                            style: const TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Кнопки
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🔄 Пройти заново',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.alternate,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '◀️ Назад к урокам',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}