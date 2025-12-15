import 'package:flutter/material.dart';
import '../models/last_read.dart';
import '../models/surah.dart';

class LastReadCard extends StatelessWidget {
  final LastRead? lastRead;
  final List<Surah> surahs;
  final String language;
  final VoidCallback onContinueReading;

  const LastReadCard({
    super.key,
    required this.lastRead,
    required this.surahs,
    required this.language,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    if (lastRead == null) {
      return const SizedBox.shrink();
    }

    final surah = surahs.firstWhere((s) => s.number == lastRead!.surah);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last Read', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Surah ${language == 'en' ? surah.englishName : surah.name}'),
            Text('Verse ${lastRead!.verse}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onContinueReading,
              child: const Text('Continue Reading'),
            ),
          ],
        ),
      ),
    );
  }
}
