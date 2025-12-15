import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/azkar_service.dart';
import '../models/zikr.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Azkar'),
      ),
      body: FutureBuilder<Map<String, List<Zikr>>>(
        future: AzkarService().getCategorizedAzkar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Azkar found'));
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.keys.length,
              itemBuilder: (context, index) {
                final category = categories.keys.elementAt(index);
                final azkar = categories[category]!;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AzkarCategoryScreen(category: category, azkar: azkar),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class AzkarCategoryScreen extends StatelessWidget {
  final String category;
  final List<Zikr> azkar;

  const AzkarCategoryScreen({super.key, required this.category, required this.azkar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: azkar.length,
        itemBuilder: (context, index) {
          final zikr = azkar[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(zikr.text, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  if (zikr.translation.isNotEmpty)
                    Text(zikr.translation, style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  if (zikr.count > 0)
                    Text('Count: ${zikr.count}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  if (zikr.reference.isNotEmpty)
                    Text('Reference: ${zikr.reference}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
