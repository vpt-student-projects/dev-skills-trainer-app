import 'package:flutter/material.dart';
import 'package:vpt_learn/services/admin_exercises_service.dart';
import '../theme.dart';

class AdminExercisesScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  const AdminExercisesScreen({super.key, required this.lessonId, required this.lessonTitle});

  @override
  State<AdminExercisesScreen> createState() => _AdminExercisesScreenState();
}

class _AdminExercisesScreenState extends State<AdminExercisesScreen> {
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  final AdminExercisesService _service = AdminExercisesService();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      _exercises = await _service.fetchExercises(widget.lessonId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createExercise() async {
    final descCtrl = TextEditingController();
    final rightCtrl = TextEditingController();
    final List<TextEditingController> answerCtrls = List.generate(4, (_) => TextEditingController());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новое задание'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Текст задания'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rightCtrl,
                decoration: const InputDecoration(labelText: 'Правильный ответ'),
              ),
              const SizedBox(height: 12),
              const Text('Варианты ответов:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(4, (i) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: answerCtrls[i],
                  decoration: InputDecoration(labelText: 'Вариант ${i + 1}'),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
    if (result != true) return;

    final answers = answerCtrls.map((c) => c.text.trim()).where((a) => a.isNotEmpty).toList();
    if (answers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужно минимум 2 варианта ответа')),
      );
      return;
    }

    try {
      await _service.createExercise(
        lessonId: widget.lessonId,
        taskDescription: descCtrl.text,
        rightAnswer: rightCtrl.text,
        answers: answers,
      );
      await _loadExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задание создано')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _editExercise(Map<String, dynamic> exercise) async {
    final descCtrl = TextEditingController(text: exercise['taskDescription']);
    final rightCtrl = TextEditingController(text: exercise['rightAnswer']);
    final List<dynamic> answersJson = exercise['answers'] ?? [];
    final List<TextEditingController> answerCtrls = List.generate(4, (i) => TextEditingController(
      text: i < answersJson.length ? answersJson[i]['answer']?.toString() ?? '' : '',
    ));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать задание'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Текст задания'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rightCtrl,
                decoration: const InputDecoration(labelText: 'Правильный ответ'),
              ),
              const SizedBox(height: 12),
              const Text('Варианты ответов:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(4, (i) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: answerCtrls[i],
                  decoration: InputDecoration(labelText: 'Вариант ${i + 1}'),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != true) return;

    final answers = answerCtrls.map((c) => c.text.trim()).where((a) => a.isNotEmpty).toList();
    if (answers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужно минимум 2 варианта ответа')),
      );
      return;
    }

    try {
      await _service.updateExercise(
        exerciseId: exercise['exerciseId'],
        taskDescription: descCtrl.text,
        rightAnswer: rightCtrl.text,
        answers: answers,
      );
      await _loadExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задание обновлено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteExercise(Map<String, dynamic> exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задание?'),
        content: Text('Вы уверены, что хотите удалить это задание?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _service.deleteExercise(exercise['exerciseId']);
      await _loadExercises();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задание удалено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Задания: ${widget.lessonTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createExercise,
            tooltip: 'Добавить задание',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? const Center(child: Text('Задания не найдены'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        title: Text(
                          exercise['taskDescription'] ?? 'Без описания',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('✅ Правильный ответ: ${exercise['rightAnswer']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editExercise(exercise),
                              tooltip: 'Редактировать',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExercise(exercise),
                              tooltip: 'Удалить',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}