import 'package:flutter/material.dart';

class BookmarksListView extends StatelessWidget {
  const BookmarksListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for now
    final bookmarks = [
      {'surah': 2, 'ayah': 255, 'note': 'Ayat al-Kursi'},
      {'surah': 18, 'ayah': 10, 'note': 'Dua from Surah Al-Kahf'},
    ];

    if (bookmarks.isEmpty) {
      return const Center(child: Text('No bookmarks yet.'));
    }

    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text('Surah ${bookmark['surah']}, Ayah ${bookmark['ayah']}'),
          subtitle: bookmark['note'] != null ? Text(bookmark['note'] as String) : null,
          onTap: () {
            // Navigate to bookmark
          },
        );
      },
    );
  }
}