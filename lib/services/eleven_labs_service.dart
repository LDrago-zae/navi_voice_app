import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

class ElevenLabsService {
  final String apiKey;
  static const String baseUrl = 'api.elevenlabs.io';

  ElevenLabsService(this.apiKey);

  Future<bool> testConnection() async {
    try {
      print(
        'ElevenLabsService: Testing connection with API key: ${apiKey.isNotEmpty ? '${apiKey.substring(0, 10)}...' : 'EMPTY'}',
      );
      final response = await http.get(
        Uri.parse('https://$baseUrl/v1/voices'),
        headers: {'xi-api-key': apiKey},
      );
      print(
        'ElevenLabsService: Test connection status: ${response.statusCode}, body: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('ElevenLabsService: Test connection error: $e');
      return false;
    }
  }

  Future<Uint8List> textToSpeech(String text, String voiceId) async {
    try {
      print(
        'ElevenLabsService: Generating speech for text: "$text", voice ID: $voiceId',
      );
      if (apiKey.isEmpty) {
        throw Exception('No ElevenLabs API key provided');
      }
      final response = await http.post(
        Uri.parse('https://$baseUrl/v1/text-to-speech/$voiceId/stream'),
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {'stability': 0.5, 'similarity_boost': 0.5},
        }),
      );
      print(
        'ElevenLabsService: API response status: ${response.statusCode}, bytes: ${response.bodyBytes.length}',
      );
      if (response.statusCode == 200) {
        if (response.bodyBytes.isNotEmpty) {
          print(
            'ElevenLabsService: Successfully generated audio, bytes: ${response.bodyBytes.length}',
          );
          return response.bodyBytes;
        } else {
          print('ElevenLabsService: Empty audio response received');
          throw Exception('Empty audio data received from ElevenLabs');
        }
      } else {
        print(
          'ElevenLabsService: Failed to generate speech, status: ${response.statusCode}, body: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}',
        );
        throw Exception(
          'Failed to generate speech: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      print('ElevenLabsService: Text-to-speech error: $e');
      throw Exception('Text-to-speech error: $e');
    }
  }
}
