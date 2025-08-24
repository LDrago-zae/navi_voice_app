import 'dart:convert';
import 'package:http/http.dart' as http;

class ORSService {
  final String apiKey;

  ORSService(this.apiKey);

  Future<List<dynamic>> getRouteSteps({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
    );
    final body = jsonEncode({
      "coordinates": [
        [startLng, startLat],
        [endLng, endLat],
      ],
      "instructions": true,
    });

    final response = await http.post(
      url,
      headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('ORS: Response data: $data');

      // Steps are in features[0].properties.segments[0].steps
      final steps = data['features'][0]['properties']['segments'][0]['steps'];
      print('ORS: Found ${steps.length} steps');
      print('ORS: First step: ${steps.isNotEmpty ? steps[0] : 'No steps'}');

      return steps;
    } else {
      print('ORS: Error response: ${response.body}');
      throw Exception('Failed to fetch route: ${response.body}');
    }
  }
}
