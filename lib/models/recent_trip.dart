class RecentTrip {
  final String location;
  final String duration;
  final String voiceArtist;

  RecentTrip({
    required this.location,
    required this.duration,
    required this.voiceArtist,
  });

  static List<RecentTrip> recentTrips = [
    RecentTrip(
      location: 'New York City, NY',
      duration: '30 min',
      voiceArtist: 'Voice Artist 1',
    ),
    RecentTrip(
      location: 'Los Angeles, CA',
      duration: '1 hr 15 min',
      voiceArtist: 'Voice Artist 2',
    ),
    RecentTrip(
      location: 'Chicago, IL',
      duration: '45 min',
      voiceArtist: 'Voice Artist 3',
    ),
  ];
}
