import 'package:flutter/material.dart';
import '../../models/voice_pack.dart';
import '../../utils/constants.dart';

class VoicePackCard extends StatelessWidget {
  final VoicePack voicePack;
  final bool isDark;
  final VoidCallback onTestVoice;

  const VoicePackCard({
    super.key,
    required this.voicePack,
    required this.isDark,
    required this.onTestVoice,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.getTextPrimary(isDark);
    final card = AppColors.getCardColor(isDark);
    final primary = AppColors.getPrimary(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: voicePack.isPremium
              ? Colors.amber.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and premium badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: voicePack.isPremium
                            ? [Colors.amber, Colors.orange]
                            : [primary, primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      voicePack.isPremium ? Icons.star : Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voicePack.artist,
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          voicePack.category,
                          style: TextStyle(
                            color: textPrimary.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (voicePack.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                voicePack.description,
                style: TextStyle(
                  color: textPrimary.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.star,
                    value: voicePack.rating.toString(),
                    label: 'Rating',
                    color: Colors.amber,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    icon: Icons.download,
                    value: voicePack.downloads,
                    label: 'Downloads',
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Bottom row with price and actions
              Row(
                children: [
                  // Price or owned status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: voicePack.isOwned
                          ? Colors.green.withOpacity(0.2)
                          : primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: voicePack.isOwned
                            ? Colors.green.withOpacity(0.5)
                            : primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          voicePack.isOwned
                              ? Icons.check_circle
                              : Icons.shopping_cart,
                          color: voicePack.isOwned ? Colors.green : primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          voicePack.isOwned ? 'OWNED' : '\$${voicePack.price}',
                          style: TextStyle(
                            color: voicePack.isOwned ? Colors.green : primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Test voice button only
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      onPressed: onTestVoice,
                      icon: Icon(Icons.volume_up, color: Colors.blue, size: 20),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    final textPrimary = AppColors.getTextPrimary(isDark);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: textPrimary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
