import 'package:mapbox_search/mapbox_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapboxService {
  final String apiKey;

  MapboxService(this.apiKey);

  Future<List<MapBoxPlace>> searchPlaces(String query) async {
    final geoCoding = GeoCodingApi(apiKey: apiKey, limit: 20);

    final response = await geoCoding.getPlaces(query);

    return response.fold(
      (success) => success,
      (failure) => throw Exception(failure.message),
    );
  }

  Future<List<MapBoxPlace>> searchPlacesWithProximity(
    String query, {
    double? proximityLat,
    double? proximityLng,
  }) async {
    String proximityParam = '';
    if (proximityLat != null && proximityLng != null) {
      proximityParam = '&proximity=$proximityLng,$proximityLat';
    }

    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$apiKey&types=poi,address,place&limit=10&language=en$proximityParam';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List;
      return features.map((feature) => MapBoxPlace.fromJson(feature)).toList();
    } else {
      throw Exception('Failed to fetch places: ${response.body}');
    }
  }
}
