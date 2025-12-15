import 'package:flutter/material.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: const Text('Daily Goal'),
        subtitle: const Text('Read 10 pages today'),
        trailing: const CircularProgressIndicator(value: 0.7), // Example progress
      ),
    );
  }
}