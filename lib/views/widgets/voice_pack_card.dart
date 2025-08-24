import 'package:flutter/material.dart';
import '../../models/voice_pack.dart';
import '../../utils/constants.dart';

class VoicePackCard extends StatelessWidget {
  final VoicePack voicePack;
  final bool isDark;
  final VoidCallback onTestVoice;
  final VoidCallback onVoiceSelectedWithPack;

  const VoicePackCard({
    super.key,
    required this.voicePack,
    required this.isDark,
    required this.onTestVoice,
    required this.onVoiceSelectedWithPack,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.getTextPrimary(isDark);
    final card = AppColors.getCardColor(isDark);

    return Card(
      color: card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onVoiceSelectedWithPack, // Trigger selection without navigation
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      voicePack.artist,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: onTestVoice, // Test voice by speaking name
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                voicePack.description,
                style: TextStyle(
                  color: textPrimary.withOpacity(0.7),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    voicePack.rating.toString(),
                    style: TextStyle(color: textPrimary, fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    voicePack.downloads,
                    style: TextStyle(
                      color: textPrimary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    voicePack.isPremium
                        ? 'Premium: \$${voicePack.price}'
                        : 'Free',
                    style: TextStyle(
                      color: voicePack.isPremium ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (voicePack.isOwned)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
