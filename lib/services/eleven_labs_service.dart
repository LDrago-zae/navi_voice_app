// import 'dart:convert';
// import 'dart:typed_data'; // Added missing import for Uint8List
// import 'package:http/http.dart' as http;
// import '../models/voice_model.dart';

// class ElevenLabsService {
//   final String apiKey;
//   static const String baseUrl = 'https://api.elevenlabs.io/v1';

//   ElevenLabsService(this.apiKey);

//   // Fetch available voices (free tier)
//   Future<List<VoiceModel>> fetchVoices() async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/voices'),
//       headers: {'xi-api-key': apiKey},
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final voices = data['voices'] ?? [];
//       return List<VoiceModel>.from(voices.map((v) => VoiceModel.fromJson(v)));
//     } else {
//       throw Exception('Failed to fetch voices: ${response.body}');
//     }
//   }

//   // Synthesize speech for a given phrase and voice
//   Future<Uint8List> synthesizeSpeech({
//     required String text,
//     required String voiceId,
//     String modelId = 'eleven_monolingual_v1',
//   }) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/text-to-speech/$voiceId'),
//       headers: {
//         'xi-api-key': apiKey,
//         'Content-Type': 'application/json',
//         'Accept': 'audio/mpeg',
//       },
//       body: json.encode({'text': text, 'model_id': modelId}),
//     );
//     if (response.statusCode == 200) {
//       return response.bodyBytes;
//     } else {
//       throw Exception('Failed to synthesize speech: ${response.body}');
//     }
//   }
// }
