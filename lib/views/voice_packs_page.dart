import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/constants.dart';
import '../models/voice_pack.dart';
import '../services/eleven_labs_service.dart';
import '../services/navigation_tts.dart';
import 'widgets/voice_pack_card.dart';
import 'widgets/custom_bottom_nav.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

class VoicePacksPage extends StatefulWidget {
  final bool isDark;
  const VoicePacksPage({super.key, this.isDark = false});

  @override
  State<VoicePacksPage> createState() => _VoicePacksPageState();
}

class _VoicePacksPageState extends State<VoicePacksPage> {
  @override
  Widget build(BuildContext context) {
    return _VoicePacksPageContent(isDark: widget.isDark);
  }
}

class _VoicePacksPageContent extends StatefulWidget {
  final bool isDark;
  const _VoicePacksPageContent({required this.isDark});

  @override
  State<_VoicePacksPageContent> createState() => _VoicePacksPageContentState();
}

class _VoicePacksPageContentState extends State<_VoicePacksPageContent> {
  String _selectedCategory = 'All';
  bool isDark = false;
  late ElevenLabsService _elevenLabsService;
  late NavigationTTS _navigationTTS;
  VoicePack? _selectedVoice;
  int _selectedIndex = 2; // VoicePacksPage index

  @override
  void initState() {
    super.initState();
    isDark = widget.isDark;
    final apiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '';
    print(
      'VoicePacksPage: Initializing with API key: ${apiKey.isNotEmpty ? '${apiKey.substring(0, 10)}...' : 'EMPTY'}',
    );
    if (apiKey.isEmpty) {
      print(
        'VoicePacksPage: WARNING - No ElevenLabs API key found in .env file!',
      );
    }
    _elevenLabsService = ElevenLabsService(apiKey);
    _navigationTTS = NavigationTTS(apiKey);
  }

  @override
  void dispose() {
    _navigationTTS.dispose();
    super.dispose();
  }

  final List<String> _categories = ['All', 'Professional', 'Character'];

  List<VoicePack> get _filteredVoicePacks {
    if (_selectedCategory == 'All') {
      return VoicePack.allVoicePacks;
    }
    return VoicePack.allVoicePacks
        .where((pack) => pack.category == _selectedCategory)
        .toList();
  }

  Future<void> _testElevenLabs() async {
    try {
      print('Testing ElevenLabs connection...');
      final apiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No API key found! Please add ELEVENLABS_API_KEY to .env file',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final success = await _elevenLabsService.testConnection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'ElevenLabs connection successful!'
                : 'ElevenLabs connection failed. Check API key.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('ElevenLabs test error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ElevenLabs test error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectVoice(VoicePack voicePack) async {
    try {
      print('Selecting voice for artist: ${voicePack.artist}');
      print('Voice pack voice ID: ${voicePack.elevenLabsVoiceId}');
      final apiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No API key found! Please add ELEVENLABS_API_KEY to .env file',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Directly select the voice without dialog
      // Speak the voice name as feedback
      await _navigationTTS.speak(voicePack.artist, voicePack.elevenLabsVoiceId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice selected: ${voicePack.artist}'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedVoice = voicePack;
      });
      // Return selected voice to MapPage
      Navigator.pop(context, voicePack);
    } catch (e) {
      print('Voice selection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice selection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testVoice(VoicePack voicePack) async {
    try {
      print('Testing voice for artist: ${voicePack.artist}');
      print('Voice pack voice ID: ${voicePack.elevenLabsVoiceId}');
      final apiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No API key found! Please add ELEVENLABS_API_KEY to .env file',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _navigationTTS.speak(
        'This is a preview of my voice for navigation.',
        voicePack.elevenLabsVoiceId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          content: Text('Playing preview of ${voicePack.artist}'),
          backgroundColor: Colors.cyan,
        ),
      );
    } catch (e) {
      print('Voice test error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice preview failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = AppColors.getBackground(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final card = AppColors.getCardColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isDark: isDark,
      ),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () {
            Navigator.pop(context, _selectedVoice);
          },
        ),
        title: Text(
          'Voice Packs',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.star,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Featured Voice Pack',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Professional Collection',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Get premium voices for enhanced navigation!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'View Bundle',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _testElevenLabs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Test ElevenLabs',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: card,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredVoicePacks.length,
                itemBuilder: (context, index) {
                  final pack = _filteredVoicePacks[index];
                  return VoicePackCard(
                    voicePack: pack,
                    isDark: isDark,
                    onTestVoice: () => _testVoice(pack),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            isDark: isDark,
            onThemeChanged: (value) {
              setState(() {
                isDark = value;
              });
            },
          ),
        ),
      );
    }
  }
}
