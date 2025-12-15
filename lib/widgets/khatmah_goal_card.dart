import 'package:flutter/material.dart';
import '../models/khatmah_goal.dart';
import '../models/last_read.dart';
import '../models/surah.dart';

class KhatmahGoalCard extends StatelessWidget {
  final KhatmahGoal? goal;
  final LastRead? lastReadMarker;
  final List<Surah> surahs;
  final String language;
  final VoidCallback onCreateGoal;
  final VoidCallback onEditGoal;
  final VoidCallback onDeleteGoal;
  final VoidCallback onContinueReading;

  const KhatmahGoalCard({
    super.key,
    this.goal,
    this.lastReadMarker,
    required this.surahs,
    required this.language,
    required this.onCreateGoal,
    required this.onEditGoal,
    required this.onDeleteGoal,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Set a Khatmah Goal'),
              ElevatedButton(
                onPressed: onCreateGoal,
                child: const Text('Create Goal'),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate progress
    double progress = 0;
    if (lastReadMarker != null) {
      // This is a simplified progress calculation. A more accurate calculation
      // would consider the number of verses in each surah.
      progress = (lastReadMarker!.surah / 114) * 100;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Khatmah Goal', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: onEditGoal),
                    IconButton(icon: const Icon(Icons.delete), onPressed: onDeleteGoal),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Goal: Finish by ${goal!.endDate.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress / 100),
            const SizedBox(height: 10),
            Text('${progress.toStringAsFixed(1)}% complete'),
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
