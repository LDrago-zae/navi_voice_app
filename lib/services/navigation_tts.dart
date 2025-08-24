import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
// import 'package:vibration/vibration.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'eleven_labs_service.dart';
import 'dart:async';

class NavigationTTS {
  final ElevenLabsService _ttsService;
  final AudioPlayer _player = AudioPlayer();

  NavigationTTS(String apiKey) : _ttsService = ElevenLabsService(apiKey) {
    if (apiKey.isEmpty) {
      print('NavigationTTS: WARNING - No ElevenLabs API key provided');
    }
  }

  Future<void> speak(String instruction, [String? voiceId]) async {
    print(
      'NavigationTTS: Speaking "$instruction" with voice ID "${voiceId ?? 'default'}"',
    );
    try {
      await _player.stop();
      final effectiveVoiceId =
          voiceId ?? 'pNInz6obpgDQGcFmaJgB'; // Default fallback (Bill)
      print('NavigationTTS: Using voice ID: $effectiveVoiceId');

      if (_ttsService.apiKey.isEmpty) {
        throw Exception(
          'No ElevenLabs API key provided. Please set ELEVENLABS_API_KEY in .env file.',
        );
      }

      final audioBytes = await _ttsService.textToSpeech(
        instruction,
        effectiveVoiceId,
      );
      print('NavigationTTS: Received ${audioBytes.length} bytes of audio');

      if (audioBytes.isNotEmpty) {
        try {
          // Save audio to temporary file
          final tempDir = await getTemporaryDirectory();
          final file = File(
            '${tempDir.path}/tts_audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
          );
          await file.writeAsBytes(audioBytes);
          print('NavigationTTS: Audio saved to ${file.path}');

          // Use AudioSource.uri for playback
          await _player.setAudioSource(AudioSource.uri(Uri.file(file.path)));
          await _player.play();
          print('NavigationTTS: Started playing audio from file');

          // if (await Vibration.hasVibrator() ?? false) {
          //   Vibration.vibrate(duration: 50);
          // }

          // Clean up temporary file after playback
          await _player.playbackEventStream.firstWhere(
            (event) => event.processingState == ProcessingState.completed,
            orElse: () => PlaybackEvent(),
          );
          await file.delete();
          print('NavigationTTS: Deleted temporary file ${file.path}');
        } catch (e) {
          print('NavigationTTS: Audio playback error: $e');
          throw Exception('Failed to play audio: $e');
        }
      } else {
        print('NavigationTTS: No audio bytes received');
        throw Exception('No audio data received from ElevenLabs');
      }
    } catch (e) {
      print('NavigationTTS: Speak error: $e');
      throw Exception('Failed to speak instruction: $e');
    }
  }

  void dispose() {
    print('NavigationTTS: Disposing audio player');
    _player.dispose();
  }

  Future<bool> testConnection() async {
    try {
      print('NavigationTTS: Testing ElevenLabs connection...');
      final audioBytes = await _ttsService.textToSpeech(
        'Hello, this is a test.',
        'pNInz6obpgDQGcFmaJgB', // Bill
      );
      print(
        'NavigationTTS: Test successful, received ${audioBytes.length} bytes',
      );
      return audioBytes.isNotEmpty;
    } catch (e) {
      print('NavigationTTS: Test failed: $e');
      return false;
    }
  }
}
