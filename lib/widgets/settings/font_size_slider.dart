import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class FontSizeSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return ListTile(
      title: const Text('Font Size'),
      subtitle: Slider(
        value: appProvider.fontSize,
        min: 12,
        max: 30,
        divisions: 18,
        label: appProvider.fontSize.round().toString(),
        onChanged: (double value) {
          appProvider.setFontSize(value);
        },
      ),
    );
  }
}