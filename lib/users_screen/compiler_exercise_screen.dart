import 'package:flutter/material.dart';
import 'package:vpt_learn/services/api_client.dart';
import '../theme.dart';

class CompilerExerciseScreen extends StatefulWidget {
  final int exerciseId;
  final String title;

  const CompilerExerciseScreen({
    super.key,
    required this.exerciseId,
    required this.title,
  });

  @override
  State<CompilerExerciseScreen> createState() => _CompilerExerciseScreenState();
}

class _CompilerExerciseScreenState extends State<CompilerExerciseScreen> {
  late TextEditingController _codeController;
  String _output = '';
  bool _isRunning = false;
  String _description = '';
  String _selectedLanguage = 'csharp'; // язык по умолчанию
  final ApiClient _api = ApiClient();

  // Список доступных языков
  final List<Map<String, String>> _languages = [
    {'value': 'csharp', 'label': 'C#'},
    {'value': 'python', 'label': 'Python'},
    {'value': 'javascript', 'label': 'JavaScript'},
    {'value': 'java', 'label': 'Java'},
    {'value': 'cpp', 'label': 'C++'},
    {'value': 'dart', 'label': 'Dart'},
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    try {
      final data = await _api.get('/controller/execute/${widget.exerciseId}');
      setState(() {
        _codeController.text = data['code'] ?? '';
        _selectedLanguage = data['language'] ?? 'csharp';
        _description = data['description'] ?? 'Выполните задание';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  Future<void> _runCode() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите код перед запуском')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _output = 'Выполнение...';
    });

    try {
      final data = await _api.post('/controller/execute', {
        'code': _codeController.text,
        'language': _selectedLanguage,
      });

      setState(() {
        if (data['error'] != null && data['error'].isNotEmpty) {
          _output = 'Ошибка:\n${data['error']}';
        } else {
          _output = data['output'] ?? '✅ Программа выполнена успешно (нет вывода)';
        }
      });
    } catch (e) {
      setState(() {
        _output = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.secondary,
        actions: [
          // Кнопка очистки кода
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _codeController.clear();
              setState(() {});
            },
            tooltip: 'Очистить код',
          ),
        ],
      ),
      body: Column(
        children: [
          // Описание задания
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryBackground,
            child: Text(
              _description,
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          
          // Выбор языка
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Язык:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    dropdownColor: AppColors.secondaryBackground,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['value'],
                        child: Text(lang['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Редактор кода
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Код на $_selectedLanguage:',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Colors.greenAccent,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Кнопка запуска
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runCode,
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Выполнение...' : 'Запустить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alternate,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          
          // Вывод
          Container(
            height: 200,
            width: double.infinity,
            color: AppColors.primaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black26,
                  child: const Text(
                    'Вывод:',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _output.isEmpty ? 'Нажмите "Запустить"' : _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
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