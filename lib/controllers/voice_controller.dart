// import 'package:flutter/material.dart';
// import '../models/voice_model.dart';
// import '../services/eleven_labs_service.dart';

// class VoiceController extends ChangeNotifier {
//   final ElevenLabsService elevenLabsService;
//   List<VoiceModel> _voices = [];
//   VoiceModel? _selectedVoice;
//   bool _loading = false;
//   String? _error;

//   VoiceController(this.elevenLabsService);

//   List<VoiceModel> get voices => _voices;
//   VoiceModel? get selectedVoice => _selectedVoice;
//   bool get loading => _loading;
//   String? get error => _error;

//   Future<void> fetchVoices() async {
//     _loading = true;
//     _error = null;
//     notifyListeners();
//     try {
//       _voices = await elevenLabsService.fetchVoices();
//       if (_voices.isNotEmpty && _selectedVoice == null) {
//         _selectedVoice = _voices.first;
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _loading = false;
//       notifyListeners();
//     }
//   }

//   void selectVoice(VoiceModel voice) {
//     _selectedVoice = voice;
//     notifyListeners();
//   }
// }
