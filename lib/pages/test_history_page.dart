import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stress_test_app/main.dart';
import 'package:stress_test_app/pages/test_detail_page.dart';
import 'package:intl/intl.dart';

class TestHistoryPage extends StatefulWidget {
  const TestHistoryPage({super.key});

  @override
  State<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends State<TestHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _testHistory = [];

  @override
  void initState() {
    super.initState();
    _loadTestHistory();
  }

  Future<void> _loadTestHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('test_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _testHistory = List<Map<String, dynamic>>.from(data);
      });
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Gagal memuat riwayat test', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Test'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _testHistory.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat test',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Lakukan test stress untuk melihat hasilnya di sini',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _testHistory.length,
        itemBuilder: (context, index) {
          final test = _testHistory[index];
          final date = DateTime.parse(test['created_at']);
          final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(date);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TestDetailPage(
                      testId: test['id'],
                      score: test['score'],
                      stressLevel: test['stress_level'],
                      date: formattedDate,
                      answers: List<int>.from(test['answers']),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        _buildStressLevelBadge(context, test['stress_level']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Skor: ${test['score']}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStressLevelBadge(BuildContext context, String stressLevel) {
    Color color;
    switch (stressLevel) {
      case 'Ringan':
        color = Colors.green;
        break;
      case 'Sedang':
        color = Colors.orange;
        break;
      case 'Berat':
        color = Colors.red;
        break;
      default:
        color = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        stressLevel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
