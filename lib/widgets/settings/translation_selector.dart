import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class TranslationSelector extends StatelessWidget {
  const TranslationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return SwitchListTile(
      title: const Text('Show Translation'),
      value: appProvider.showTranslation,
      onChanged: (bool value) {
        appProvider.setShowTranslation(value);
      },
    );
  }
}