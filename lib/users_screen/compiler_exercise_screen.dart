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
  String _language = 'csharp';
  final ApiClient _api = ApiClient();

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
        _language = data['language'] ?? 'csharp';
        _description = data['description'] ?? 'Выполните задание';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = 'Выполнение...';
    });

    try {
      final data = await _api.post('/controller/execute', {
        'code': _codeController.text,
        'language': _language,
      });

      setState(() {
        _output = data['output'] ?? 'Нет вывода';
        if (data['error'] != null && data['error'].isNotEmpty) {
          _output = 'Ошибка:\n${data['error']}';
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
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryBackground,
            child: Text(_description, style: TextStyle(color: AppColors.secondaryText)),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Код на $_language:', style: TextStyle(color: AppColors.primaryText)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent),
                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runCode,
              icon: _isRunning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'Выполнение...' : 'Запустить'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alternate, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: AppColors.primaryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.all(8), color: Colors.black26, child: const Text('Вывод:', style: TextStyle(color: Colors.white))),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(_output.isEmpty ? 'Нажмите "Запустить"' : _output, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
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