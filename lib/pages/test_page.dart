import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stress_test_app/main.dart';
import 'package:stress_test_app/pages/test_result_page.dart';
import 'package:stress_test_app/models/question.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final PageController _pageController = PageController();
  bool _isLoading = true;
  List<Question> _questions = [];
  List<int> _answers = [];
  int _currentPage = 0;

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
        _answers = List.filled(_questions.length, 0);
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

  Future<void> _submitTest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate score
      int totalScore = _answers.reduce((a, b) => a + b);

      // Determine stress level
      String stressLevel;
      if (totalScore <= 15) {
        stressLevel = 'Ringan';
      } else if (totalScore <= 30) {
        stressLevel = 'Sedang';
      } else {
        stressLevel = 'Berat';
      }

      // Save test result to database
      final userId = supabase.auth.currentUser!.id;
      final result = await supabase.from('test_history').insert({
        'user_id': userId,
        'score': totalScore,
        'stress_level': stressLevel,
        'answers': _answers,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TestResultPage(
              score: totalScore,
              stressLevel: stressLevel,
              testId: result[0]['id'],
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Gagal menyimpan hasil test', isError: true);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int questionIndex, int value) {
    setState(() {
      _answers[questionIndex] = value;

      // Auto navigate to next question if not on the last page
      if (questionIndex < _questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuesioner Stress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pertanyaan ${_currentPage + 1} dari ${_questions.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${((_currentPage + 1) / _questions.length * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _questions[index].text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(5, (valueIndex) {
                        final value = valueIndex;
                        return RadioListTile<int>(
                          title: Text(_getAnswerLabel(value)),
                          value: value,
                          groupValue: _answers[index],
                          onChanged: (val) {
                            if (val != null) {
                              _selectAnswer(index, val);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox(),
                if (_currentPage < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Selanjutnya'),
                  )
                else
                  ElevatedButton(
                    onPressed: _answers.contains(0) ? null : _submitTest,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Selesai'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAnswerLabel(int value) {
    switch (value) {
      case 0:
        return 'Pilih jawaban';
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
}
