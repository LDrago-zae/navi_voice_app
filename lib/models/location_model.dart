import 'package:geolocator/geolocator.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? name;
  final double? bearing;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.name,
    this.bearing,
  });

  factory LocationModel.fromPosition(Position position, {String? name}) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      name: name,
      bearing: position.heading,
    );
  }
}
