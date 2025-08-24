import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.cardDark : AppColors.card;
    final selected = isDark ? AppColors.primaryDark : AppColors.primary;
    final unselected = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 20.0 : 10.0,
            vertical: 8,
          ),
          child: GNav(
            rippleColor: selected.withValues(alpha: 0.1),
            hoverColor: selected.withValues(alpha: 0.05),
            gap: MediaQuery.of(context).size.width > 600 ? 12 : 8,
            activeColor: selected,
            iconSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
              vertical: MediaQuery.of(context).size.width > 600 ? 14 : 10,
            ),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: selected.withValues(alpha: 0.1),
            color: unselected,
            selectedIndex: currentIndex,
            onTabChange: onTap,
            tabs: [
              GButton(
                icon: Icons.home,
                iconSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                text: 'Home',
                textStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GButton(
                icon: FontAwesomeIcons.map,
                iconSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                text: 'Maps',
                textStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GButton(
                icon: FontAwesomeIcons.headphones,
                iconSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                text: 'Voice Packs',
                textStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              GButton(
                icon: FontAwesomeIcons.person,
                iconSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                text: 'Profile',
                textStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
