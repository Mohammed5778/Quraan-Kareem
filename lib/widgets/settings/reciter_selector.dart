import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/reciter.dart';

class ReciterSelector extends StatelessWidget {
  final List<Reciter> reciters;

  const ReciterSelector({super.key, required this.reciters});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return ListTile(
      title: const Text('Reciter'),
      trailing: DropdownButton<String>(
        value: appProvider.reciter,
        onChanged: (String? newValue) {
          if (newValue != null) {
            appProvider.setReciter(newValue);
          }
        },
        items: reciters.map((reciter) {
          return DropdownMenuItem<String>(
            value: reciter.identifier,
            child: Text(reciter.name),
          );
        }).toList(),
      ),
    );
  }
}