import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/recommended_voice.dart';

class RecommendedVoiceCard extends StatelessWidget {
  final RecommendedVoice voice;
  final bool isDark;
  const RecommendedVoiceCard({
    Key? key,
    required this.voice,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = AppColors.getCardColor(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final priceTag = AppColors.getPriceTag(isDark);
    final priceText = AppColors.getPriceText(isDark);
    final yellowTag = AppColors.getYellowTag(isDark);
    final star = AppColors.getStar(isDark);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey[700],
            child: Icon(Icons.person, color: priceText),
          ),
          const SizedBox(width: 12),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voice.artist,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: star, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 13,
                        color: textPrimary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: yellowTag,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Gal Gadot',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_arrow_rounded, color: textPrimary),
            onPressed: () {},
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: priceTag,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              voice.price,
              style: TextStyle(color: priceText, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
