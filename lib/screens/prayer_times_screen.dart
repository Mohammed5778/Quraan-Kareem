import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/prayer_time_service.dart';
import '../models/prayer_times.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  Future<PrayerTimes>? _prayerTimesFuture;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  void _loadPrayerTimes() {
    setState(() {
      _prayerTimesFuture = _prayerTimeService.getCurrentLocation().then((position) {
        return _prayerTimeService.getPrayerTimesByCoordinates(
          position.latitude,
          position.longitude,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
      ),
      body: FutureBuilder<PrayerTimes>(
        future: _prayerTimesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No prayer times found'));
          } else {
            final prayerTimes = snapshot.data!;
            final nextPrayer = _prayerTimeService.getNextPrayer(prayerTimes);
            final timeUntilNext = _prayerTimeService.getTimeUntilNextPrayer(prayerTimes);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Next Prayer: $nextPrayer', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Time remaining: ${timeUntilNext.inHours}:${(timeUntilNext.inMinutes % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildPrayerTimeRow('Fajr', prayerTimes.timings.fajr),
                          _buildPrayerTimeRow('Sunrise', prayerTimes.timings.sunrise),
                          _buildPrayerTimeRow('Dhuhr', prayerTimes.timings.dhuhr),
                          _buildPrayerTimeRow('Asr', prayerTimes.timings.asr),
                          _buildPrayerTimeRow('Maghrib', prayerTimes.timings.maghrib),
                          _buildPrayerTimeRow('Isha', prayerTimes.timings.isha),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 18)),
          Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
