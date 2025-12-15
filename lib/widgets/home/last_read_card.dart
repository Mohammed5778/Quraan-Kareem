import 'package:flutter/material.dart';
import '../../models/khatmah_goal.dart';

class LastReadCard extends StatelessWidget {
  final LastReadMarker lastRead;

  const LastReadCard({super.key, required this.lastRead});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history),
        title: const Text('Last Read'),
        subtitle: Text('Surah ${lastRead.surah}, Ayah ${lastRead.ayah}'),
        trailing: ElevatedButton(
          child: const Text('Continue'),
          onPressed: () {
            // Navigate to last read position
          },
        ),
      ),
    );
  }
}