import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/voice_pack.dart';

class VoicePackCard extends StatelessWidget {
  final VoicePack voicePack;
  final bool isDark;
  const VoicePackCard({Key? key, required this.voicePack, this.isDark = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = AppColors.getCardColor(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final yellowTag = AppColors.getYellowTag(isDark);
    final primary = AppColors.getPrimary(isDark);
    final greenLight = AppColors.getGreenLight(isDark);
    final green = AppColors.getGreen(isDark);
    final priceTag = AppColors.getPriceTag(isDark);
    final priceText = AppColors.getPriceText(isDark);
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and premium badge
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: voicePack.isPremium
                      ? primary
                      : Colors.grey[700],
                  child: Icon(
                    voicePack.isPremium ? Icons.star : Icons.person,
                    color: voicePack.isPremium ? Colors.white : textPrimary,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (voicePack.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: yellowTag,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Artist name and description
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voicePack.artist,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voicePack.description,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Rating and downloads
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        voicePack.rating.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.download, color: textSecondary, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        voicePack.downloads,
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow, size: 18, color: primary),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                if (voicePack.isOwned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: greenLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'OWNED',
                      style: TextStyle(
                        color: green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priceTag,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      voicePack.price,
                      style: TextStyle(
                        color: priceText,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
