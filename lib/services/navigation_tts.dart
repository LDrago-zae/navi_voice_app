// import 'dart:typed_data';
// import 'package:just_audio/just_audio.dart';
// import '../controllers/voice_controller.dart';
// import 'eleven_labs_service.dart';

// class NavigationTTS {
//   final ElevenLabsService elevenLabsService;
//   final VoiceController voiceController;
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   NavigationTTS({
//     required this.elevenLabsService,
//     required this.voiceController,
//   });

//   Future<void> speak(String phrase) async {
//     final selectedVoice = voiceController.selectedVoice;
//     if (selectedVoice == null) {
//       throw Exception('No voice selected for navigation TTS');
//     }
//     try {
//       Uint8List audioBytes = await elevenLabsService.synthesizeSpeech(
//         text: phrase,
//         voiceId: selectedVoice.id,
//       );
//       await _audioPlayer.setAudioSource(
//         AudioSource.uri(Uri.dataFromBytes(audioBytes)),
//       );
//       await _audioPlayer.play();
//     } catch (e) {
//       // Optionally: fallback to a default voice or show error
//       rethrow;
//     }
//   }

//   void dispose() {
//     _audioPlayer.dispose();
//   }
// }
