import 'package:flutter/material.dart';
import 'package:stress_test_app/pages/home_page.dart';

class TestResultPage extends StatelessWidget {
  final int score;
  final String stressLevel;
  final int testId;

  const TestResultPage({
    super.key,
    required this.score,
    required this.stressLevel,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Test'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        _getStressIcon(),
                        size: 80,
                        color: _getStressColor(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tingkat Stress: $stressLevel',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStressColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skor: $score',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getStressDescription(),
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getRecommendations().map((recommendation) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(recommendation)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => false,
                    );
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStressIcon() {
    switch (stressLevel) {
      case 'Ringan':
        return Icons.sentiment_satisfied;
      case 'Sedang':
        return Icons.sentiment_neutral;
      case 'Berat':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.psychology;
    }
  }

  Color _getStressColor(BuildContext context) {
    switch (stressLevel) {
      case 'Ringan':
        return Colors.green;
      case 'Sedang':
        return Colors.orange;
      case 'Berat':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getStressDescription() {
    switch (stressLevel) {
      case 'Ringan':
        return 'Anda mengalami stress dalam tingkat yang normal dan masih dapat dikelola dengan baik.';
      case 'Sedang':
        return 'Anda mengalami stress yang cukup signifikan. Pertimbangkan untuk mengurangi beban dan meningkatkan aktivitas relaksasi.';
      case 'Berat':
        return 'Anda mengalami stress yang tinggi. Disarankan untuk berkonsultasi dengan profesional kesehatan mental.';
      default:
        return '';
    }
  }

  List<String> _getRecommendations() {
    switch (stressLevel) {
      case 'Ringan':
        return [
          'Pertahankan keseimbangan hidup yang baik',
          'Lakukan aktivitas fisik secara teratur',
          'Jaga pola tidur yang cukup',
          'Luangkan waktu untuk hobi dan relaksasi',
        ];
      case 'Sedang':
        return [
          'Identifikasi sumber stress dan coba untuk menguranginya',
          'Praktikkan teknik relaksasi seperti meditasi atau pernapasan dalam',
          'Tingkatkan aktivitas fisik untuk mengurangi ketegangan',
          'Pertimbangkan untuk berbagi masalah dengan orang terdekat',
          'Atur jadwal istirahat yang cukup',
        ];
      case 'Berat':
        return [
          'Segera konsultasikan dengan profesional kesehatan mental',
          'Kurangi beban kerja atau aktivitas yang menyebabkan stress',
          'Praktikkan teknik manajemen stress secara intensif',
          'Jaga komunikasi dengan keluarga dan teman terdekat',
          'Prioritaskan kesehatan dan istirahat yang cukup',
          'Pertimbangkan untuk mengikuti terapi atau konseling',
        ];
      default:
        return [];
    }
  }
}
