import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/recent_trip.dart';

class RecentTripCard extends StatelessWidget {
  final RecentTrip trip;
  final bool isDark;
  const RecentTripCard({super.key, required this.trip, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final card = AppColors.getCardColor(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final greenLight = AppColors.getGreenLight(isDark);
    final blueLight = AppColors.getBlueLight(isDark);
    final green = AppColors.getGreen(isDark);
    final blue = AppColors.getBlue(isDark);
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
            radius: 18,
            backgroundColor: trip.location.contains('Airport')
                ? greenLight
                : blueLight,
            child: Icon(
              trip.location.contains('Airport')
                  ? Icons.local_taxi
                  : Icons.location_on,
              color: trip.location.contains('Airport') ? green : blue,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.location,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '12.5 miles · 25 min',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
              left: 16.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Today',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                  textAlign: TextAlign.end,
                ),
                Text(
                  'Sarah Chen',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 13,
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
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
