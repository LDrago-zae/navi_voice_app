import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

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
      // Steps are in features[0].properties.segments[0].steps
      return data['features'][0]['properties']['segments'][0]['steps'];
    } else {
      throw Exception('Failed to fetch route: ${response.body}');
    }
  }
}

class NavigationTTS {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String instruction) async {
    await _tts.stop();
    await _tts.speak(instruction);
  }

  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }
}
