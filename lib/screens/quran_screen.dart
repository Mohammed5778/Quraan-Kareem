import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/surah_list_tile.dart';
import '../screens/surah_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SurahSearchDelegate(appProvider.surahs));
            },
          ),
        ],
      ),
      body: appProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: appProvider.filteredSurahs.length,
              itemBuilder: (context, index) {
                final surah = appProvider.filteredSurahs[index];
                return SurahListTile(
                  surah: surah,
                  language: appProvider.currentLanguage,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahScreen(surahNumber: surah.number),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class SurahSearchDelegate extends SearchDelegate {
  final List<dynamic> surahs;

  SurahSearchDelegate(this.surahs);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = surahs
        .where((surah) =>
            surah.name.toLowerCase().contains(query.toLowerCase()) ||
            surah.englishName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final surah = results[index];
        return SurahListTile(
          surah: surah,
          language: 'en', // Or get from provider
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahScreen(surahNumber: surah.number),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = surahs
        .where((surah) =>
            surah.name.toLowerCase().contains(query.toLowerCase()) ||
            surah.englishName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final surah = results[index];
        return SurahListTile(
          surah: surah,
          language: 'en', // Or get from provider
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahScreen(surahNumber: surah.number),
              ),
            );
          },
        );
      },
    );
  }
}
