import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class TafsirSelector extends StatelessWidget {
  const TafsirSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return SwitchListTile(
      title: const Text('Show Tafsir'),
      value: appProvider.showTafsir,
      onChanged: (bool value) {
        appProvider.setShowTafsir(value);
      },
    );
  }
}