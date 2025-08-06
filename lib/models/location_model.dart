import 'package:geolocator/geolocator.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? name;

  LocationModel({required this.latitude, required this.longitude, this.name});

  factory LocationModel.fromPosition(Position position, {String? name}) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      name: name,
    );
  }
}
