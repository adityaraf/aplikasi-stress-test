import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stress_test_app/main.dart';
import 'package:stress_test_app/models/question.dart';

class TestDetailPage extends StatefulWidget {
  final int testId;
  final int score;
  final String stressLevel;
  final String date;
  final List<int> answers;

  const TestDetailPage({
    super.key,
    required this.testId,
    required this.score,
    required this.stressLevel,
    required this.date,
    required this.answers,
  });

  @override
  State<TestDetailPage> createState() => _TestDetailPageState();
}

class _TestDetailPageState extends State<TestDetailPage> {
  bool _isLoading = true;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await supabase
          .from('questions')
          .select()
          .order('id', ascending: true);

      setState(() {
        _questions = data.map((q) => Question.fromJson(q)).toList();
      });
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Gagal memuat pertanyaan', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStressColor() {
    switch (widget.stressLevel) {
      case 'Ringan':
        return Colors.green;
      case 'Sedang':
        return Colors.orange;
      case 'Berat':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Test'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hasil Test',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStressColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _getStressColor()),
                            ),
                            child: Text(
                              widget.stressLevel,
                              style: TextStyle(
                                color: _getStressColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tanggal: ${widget.date}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skor: ${widget.score}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Jawaban Anda',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._questions.isNotEmpty
                  ? List.generate(
                _questions.length,
                    (index) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertanyaan ${index + 1}:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _questions[index].text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jawaban:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _getAnswerLabel(widget.answers[index]),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getAnswerColor(widget.answers[index]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : [
                const Center(
                  child: Text('Tidak ada data pertanyaan'),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getAnswerLabel(int value) {
    switch (value) {
      case 0:
        return 'Tidak dijawab';
      case 1:
        return 'Tidak pernah';
      case 2:
        return 'Jarang';
      case 3:
        return 'Kadang-kadang';
      case 4:
        return 'Sering';
      case 5:
        return 'Sangat sering';
      default:
        return '';
    }
  }

  Color _getAnswerColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
