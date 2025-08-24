import 'package:flutter/material.dart';
import 'package:navi_voice_app/models/voice_pack.dart';
import '../utils/constants.dart';
import 'map_page.dart';
import '../models/recommended_voice.dart';
import '../models/recent_trip.dart';
import 'profile_page.dart';
import 'widgets/custom_bottom_nav.dart';
import 'voice_packs_page.dart';
import 'widgets/recommended_voice_card.dart';
import 'widgets/recent_trip_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool isDark = false;
  VoicePack? _selectedVoice; // Store selected voice for MapPage

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VoicePacksPage(isDark: isDark)),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProfilePage(isDark: isDark, onThemeChanged: _toggleTheme),
        ),
      );
    }
  }

  void _toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  void _switchToMap() {
    setState(() {
      _selectedIndex = 1; // MapPage tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      body: HomeScreenContent(isDark: isDark),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isDark: isDark,
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final bool isDark;
  const HomeScreenContent({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getBackground(isDark);
    final card = AppColors.getCardColor(isDark);
    final cardShadow = AppColors.getCardShadow(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final primary = AppColors.getPrimary(isDark);
    final primaryLight = AppColors.getPrimaryLight(isDark);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 70.0,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [primary, primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: card,
                            child: Icon(Icons.person, size: 36, color: primary),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'John Doe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          Icon(
                            Icons.settings,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.person_outline,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This Month',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '2.4K miles',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Voice Packs',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '12',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Start',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flex(
                        direction: constraints.maxWidth > 500
                            ? Axis.horizontal
                            : Axis.vertical,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Switch to MapPage tab
                              _HomePageState? homeState = context
                                  .findAncestorStateOfType<_HomePageState>();
                              homeState?._onItemTapped(1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.navigation, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Start Navigation',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth > 500 ? 12 : 0,
                            height: constraints.maxWidth > 500 ? 0 : 12,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              // Switch to VoicePacksPage tab
                              _HomePageState? homeState = context
                                  .findAncestorStateOfType<_HomePageState>();
                              homeState?._onItemTapped(2);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(color: primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.headphones, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Browse Voices',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recommended for You',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Switch to VoicePacksPage tab
                              _HomePageState? homeState = context
                                  .findAncestorStateOfType<_HomePageState>();
                              homeState?._onItemTapped(2);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primary,
                            ),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...RecommendedVoice.recommendedVoices
                          .take(2)
                          .map(
                            (voice) => RecommendedVoiceCard(
                              voice: voice,
                              isDark: isDark,
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Trips',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...RecentTrip.recentTrips
                          .take(3)
                          .map(
                            (trip) =>
                                RecentTripCard(trip: trip, isDark: isDark),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
