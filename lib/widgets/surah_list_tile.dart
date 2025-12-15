import 'package:flutter/material.dart';
import '../models/surah.dart';

class SurahListTile extends StatelessWidget {
  final Surah surah;
  final String language;
  final VoidCallback onTap;

  const SurahListTile({
    super.key,
    required this.surah,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(surah.number.toString()),
      ),
      title: Text(language == 'en' ? surah.englishName : surah.name),
      subtitle: Text(
        '${language == 'en' ? surah.englishNameTranslation : surah.name} - ${surah.numberOfAyahs} verses',
      ),
      trailing: Text(surah.revelationType, style: const TextStyle(fontStyle: FontStyle.italic)),
      onTap: onTap,
    );
  }
}
