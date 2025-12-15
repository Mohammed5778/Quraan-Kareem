import 'package:flutter/material.dart';
import '../../models/adhkar.dart';

class AdhkarDetailScreen extends StatelessWidget {
  final AdhkarCategory category;

  const AdhkarDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: ListView.builder(
        itemCount: category.adhkar.length,
        itemBuilder: (context, index) {
          final dhikr = category.adhkar[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dhikr.content, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  if (dhikr.description != null)
                    Text(dhikr.description!, style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  Text('Repeat: ${dhikr.count}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}