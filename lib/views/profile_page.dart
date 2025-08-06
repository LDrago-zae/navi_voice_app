import 'package:flutter/material.dart';
import 'package:navi_voice_app/views/widgets/custom_bottom_nav.dart';
import '../utils/constants.dart';
import 'package:navi_voice_app/views/home_page.dart';
import 'package:navi_voice_app/views/map_page.dart';
import 'package:navi_voice_app/views/voice_packs_page.dart';

class ProfilePage extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  const ProfilePage({
    Key? key,
    required this.isDark,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  late bool isDark;

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VoicePacksPage()),
        );
        break;
      case 3:
        // Stay on Profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final card = isDark ? AppColors.cardDark : AppColors.card;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final primaryLight = isDark
        ? AppColors.primaryLightDark
        : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: primaryLight,
                child: Icon(Icons.person, size: 56, color: primary),
              ),
              const SizedBox(height: 24),
              Text(
                'John Doe',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'john.doe@email.com',
                style: TextStyle(color: textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Card(
                color: card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Voice Packs',
                            style: TextStyle(color: textSecondary),
                          ),
                          Text(
                            '12',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Miles Driven',
                            style: TextStyle(color: textSecondary),
                          ),
                          Text(
                            '2.4K',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      setState(() {
                        isDark = value;
                      });
                      widget.onThemeChanged(value);
                    },
                    activeColor: primary,
                    inactiveThumbColor: primaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                ),
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
