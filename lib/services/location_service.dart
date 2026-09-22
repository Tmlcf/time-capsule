import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Check if user is within radius of a capsule's location
  bool isWithinRadius({
    required double userLat,
    required double userLng,
    required double capsuleLat,
    required double capsuleLng,
    required int radiusMeters,
  }) {
    final distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      capsuleLat,
      capsuleLng,
    );
    return distance <= radiusMeters;
  }

  /// Distance in meters between two coordinates
  double distanceBetween({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // notify every 10 metres
      ),
    );
  }

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();
}
