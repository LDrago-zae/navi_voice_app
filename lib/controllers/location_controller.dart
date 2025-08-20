import '../services/geolocation_service.dart';
import '../models/location_model.dart';

class LocationController {
  final GeolocationService _geolocationService;

  LocationController(this._geolocationService);

  Future<LocationModel> getCurrentLocation() async {
    final position = await _geolocationService.getCurrentLocation();
    return LocationModel.fromPosition(position);
  }

  Stream<LocationModel> get locationStream => _geolocationService.locationStream
      .map((position) => LocationModel.fromPosition(position));
}
