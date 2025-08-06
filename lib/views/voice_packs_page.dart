import 'package:flutter/material.dart';
import 'package:navi_voice_app/views/profile_page.dart';
import 'package:navi_voice_app/views/widgets/custom_bottom_nav.dart';
import '../utils/constants.dart';
import '../models/voice_pack.dart';
import 'widgets/voice_pack_card.dart';
import 'home_page.dart';
import 'map_page.dart';

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

  const _VoicePacksPageContent({super.key, required this.isDark});

  @override
  State<_VoicePacksPageContent> createState() => _VoicePacksPageContentState();
}

class _VoicePacksPageContentState extends State<_VoicePacksPageContent> {
  String _selectedCategory = 'All';
  int _selectedIndex = 2;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    isDark = widget.isDark;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapPage()),
        );
        break;
      case 2:
        // Stay on Voice Packs
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              isDark: isDark,
              onThemeChanged: (bool value) {
                setState(() {
                  isDark = value;
                });
              },
            ),
          ),
        );
        break;
    }
  }

  final List<String> _categories = [
    'All',
    'Celebrity',
    'Character',
    'Language',
    'Premium',
  ];

  List<VoicePack> get _filteredVoicePacks {
    if (_selectedCategory == 'All') {
      return VoicePack.allVoicePacks;
    }
    return VoicePack.allVoicePacks
        .where((pack) => pack.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = AppColors.getBackground(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final card = AppColors.getCardColor(isDark);
    final cardShadow = AppColors.getCardShadow(isDark);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
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
              // Featured Voice Pack Card
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
                                'Celebrity Collection',
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
                      'Get 3 premium celebrity voices for the price of 2!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Filter
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

              // Voice Packs Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filteredVoicePacks.length,
                itemBuilder: (context, index) {
                  final pack = _filteredVoicePacks[index];
                  return VoicePackCard(voicePack: pack, isDark: isDark);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isDark: isDark,
      ),
    );
  }
}
