import 'package:flutter/material.dart';
import '../models/verse.dart';

class AyahListItem extends StatelessWidget {
  final Verse ayah;
  final String language;
  final double fontSize;
  final bool showTranslation;
  final bool showTafsir;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onPlay;
  final VoidCallback onShare;

  const AyahListItem({
    super.key,
    required this.ayah,
    required this.language,
    required this.fontSize,
    required this.showTranslation,
    required this.showTafsir,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onPlay,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '(${ayah.numberInSurah}) ${ayah.text}',
            style: TextStyle(fontSize: fontSize, fontFamily: 'Quran'),
            textAlign: TextAlign.right,
          ),
          if (showTranslation)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(ayah.translation, style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          if (showTafsir)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(ayah.tafsir, style: const TextStyle(color: Colors.grey)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: onBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: onPlay,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: onShare,
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
