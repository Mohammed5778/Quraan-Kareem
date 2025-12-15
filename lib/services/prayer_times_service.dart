import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';

class PrayerTimesService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  PrayerTimes getPrayerTimes(Position position) {
    final myCoordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    return prayerTimes;
  }

  String getNextPrayer(Position position) {
    final prayerTimes = getPrayerTimes(position);
    return prayerTimes.nextPrayer().toString().split('.').last;
  }

  double getQiblaDirection(Position position) {
    final myCoordinates = Coordinates(position.latitude, position.longitude);
    final qibla = Qibla(myCoordinates);
    return qibla.direction;
  }

  Map<String, DateTime> getAllPrayerTimes(Position position) {
    final prayerTimes = getPrayerTimes(position);
    return {
      'fajr': prayerTimes.fajr,
      'sunrise': prayerTimes.sunrise,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    };
  }
}