import 'package:flutter/material.dart';
import '../../utils/quran_meta.dart';

class JuzListView extends StatelessWidget {
  const JuzListView({super.key});

  @override
  Widget build(BuildContext context) {
    final juzList = QuranMeta.juz;
    if (juzList.isEmpty) {
      return const Center(child: Text('Juz data not loaded yet.'));
    }

    return ListView.builder(
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        final juz = juzList[index];
        return ListTile(
          leading: Text(juz.juzNumber.toString()),
          title: Text('Juz ${juz.juzNumber}'),
          subtitle: Text('Starts from Surah ${juz.startSurah}, Ayah ${juz.startAyah}'),
          onTap: () {
            // Navigate to the start of the Juz
          },
        );
      },
    );
  }
}