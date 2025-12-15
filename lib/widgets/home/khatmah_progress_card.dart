import 'package:flutter/material.dart';
import '../../models/khatmah_goal.dart';

class KhatmahProgressCard extends StatelessWidget {
  final KhatmahGoal goal;

  const KhatmahProgressCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (DateTime.now().difference(goal.startDate).inDays / goal.duration).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Khatmah Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(1)}% complete'),
          ],
        ),
      ),
    );
  }
}