import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/last_read_card.dart';
import '../widgets/khatmah_goal_card.dart';
import '../screens/quran_screen.dart';
import '../screens/surah_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assalamu Alaikum',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              LastReadCard(
                lastRead: appProvider.lastRead,
                surahs: appProvider.surahs,
                language: appProvider.currentLanguage,
                onContinueReading: () {
                  if (appProvider.lastRead != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahScreen(surahNumber: appProvider.lastRead!.surah),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              KhatmahGoalCard(
                goal: appProvider.khatmahGoal,
                lastReadMarker: appProvider.lastRead,
                surahs: appProvider.surahs,
                language: appProvider.currentLanguage,
                onCreateGoal: () {},
                onEditGoal: () {},
                onDeleteGoal: () {},
                onContinueReading: () {
                  if (appProvider.lastRead != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahScreen(surahNumber: appProvider.lastRead!.surah),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
