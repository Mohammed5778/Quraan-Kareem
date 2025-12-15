import 'package:flutter/material.dart';
import '../../models/surah.dart';
import '../../screens/surah_screen.dart';

class SurahListView extends StatelessWidget {
  final List<Surah> surahs;

  const SurahListView({super.key, required this.surahs});

  @override
  Widget build(BuildContext context) {
    if (surahs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          leading: Text(surah.number.toString()),
          title: Text(surah.name),
          subtitle: Text('${surah.revelationType} - ${surah.numberOfAyahs} verses'),
          trailing: Text(surah.englishNameTranslation),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahScreen(surah: surah),
              ),
            );
          },
        );
      },
    );
  }
}