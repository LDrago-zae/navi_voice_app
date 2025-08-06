import 'package:mapbox_search/mapbox_search.dart';

class MapboxService {
  final String apiKey;

  MapboxService(this.apiKey);

  Future<List<MapBoxPlace>> searchPlaces(String query) async {
    final geoCoding = GeoCodingApi(
      apiKey: apiKey,
      limit: 20,
    );

    final response = await geoCoding.getPlaces(query);

    return response.fold(
          (success) => success,
          (failure) => throw Exception(failure.message),
    );
  }
}