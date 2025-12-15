import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../models/prayer_times.dart';

class PrayerTimeService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  // Get prayer times by coordinates
  Future<PrayerTimes> getPrayerTimesByCoordinates(
    double latitude,
    double longitude, {
    int method = 4, // Egyptian General Authority of Survey
  }) async {
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/timings/${now.day}-${now.month}-${now.year}?latitude=$latitude&longitude=$longitude&method=$method',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data['data']);
      }
      throw Exception('Failed to load prayer times');
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  // Get prayer times by city
  Future<PrayerTimes> getPrayerTimesByCity(
    String city,
    String country, {
    int method = 4,
  }) async {
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/timingsByCity/${now.day}-${now.month}-${now.year}?city=$city&country=$country&method=$method',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimes.fromJson(data['data']);
      }
      throw Exception('Failed to load prayer times');
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // Get next prayer
  String getNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    final timings = prayerTimes.timings;
    
    final prayers = [
      {'name': 'Fajr', 'time': _parseTime(timings.fajr)},
      {'name': 'Sunrise', 'time': _parseTime(timings.sunrise)},
      {'name': 'Dhuhr', 'time': _parseTime(timings.dhuhr)},
      {'name': 'Asr', 'time': _parseTime(timings.asr)},
      {'name': 'Maghrib', 'time': _parseTime(timings.maghrib)},
      {'name': 'Isha', 'time': _parseTime(timings.isha)},
    ];

    for (var prayer in prayers) {
      final prayerTime = prayer['time'] as DateTime;
      if (prayerTime.isAfter(now)) {
        return prayer['name'] as String;
      }
    }

    return 'Fajr'; // Next day's Fajr
  }

  // Get time remaining until next prayer
  Duration getTimeUntilNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    final nextPrayer = getNextPrayer(prayerTimes);
    final timings = prayerTimes.timings;
    
    DateTime nextPrayerTime;
    switch (nextPrayer) {
      case 'Fajr':
        nextPrayerTime = _parseTime(timings.fajr);
        if (nextPrayerTime.isBefore(now)) {
          nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
        }
        break;
      case 'Sunrise':
        nextPrayerTime = _parseTime(timings.sunrise);
        break;
      case 'Dhuhr':
        nextPrayerTime = _parseTime(timings.dhuhr);
        break;
      case 'Asr':
        nextPrayerTime = _parseTime(timings.asr);
        break;
      case 'Maghrib':
        nextPrayerTime = _parseTime(timings.maghrib);
        break;
      case 'Isha':
        nextPrayerTime = _parseTime(timings.isha);
        break;
      default:
        nextPrayerTime = _parseTime(timings.fajr);
    }

    return nextPrayerTime.difference(now);
  }

  DateTime _parseTime(String timeString) {
    final now = DateTime.now();
    final parts = timeString.split(' ')[0].split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}