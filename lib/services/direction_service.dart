import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class DirectionsService {
  final String apiKey;
  final Dio _dio = Dio();

  DirectionsService(this.apiKey);

  Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
    final coordinates =
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}';
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '$coordinates'
        '?geometries=geojson'
        '&steps=true'
        '&overview=full'
        '&access_token=$apiKey';

    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final routes = data['routes'];
      if (routes == null || routes.isEmpty) {
        throw Exception('No route found');
      }

      return (routes[0]['geometry']['coordinates'] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Failed to get route: ${response.statusMessage}');
    }
  }
}
