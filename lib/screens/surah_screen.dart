import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/ayah_list_item.dart';
import '../widgets/audio_player_bar.dart';

class SurahScreen extends StatefulWidget {
  final int surahNumber;

  const SurahScreen({super.key, required this.surahNumber});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false)
          .loadSurahVerses(widget.surahNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.currentSurah?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings
            },
          ),
        ],
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: appProvider.currentVerses.length,
                    itemBuilder: (context, index) {
                      final ayah = appProvider.currentVerses[index];
                      return AyahListItem(
                        ayah: ayah,
                        language: appProvider.currentLanguage,
                        fontSize: appProvider.fontSize,
                        showTranslation: appProvider.showTranslation,
                        showTafsir: appProvider.showTafsir,
                        isBookmarked: appProvider.isBookmarked(widget.surahNumber, ayah.numberInSurah),
                        onBookmark: () {
                          appProvider.toggleBookmark(widget.surahNumber, ayah.numberInSurah);
                        },
                        onPlay: () {
                          appProvider.audioService.playVerse(ayah.number, appProvider.getCurrentReciter()!);
                        },
                        onShare: () {
                          // Share logic
                        },
                      );
                    },
                  ),
                ),
                const AudioPlayerBar(),
              ],
            ),
    );
  }
}
