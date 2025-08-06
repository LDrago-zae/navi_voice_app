class RecommendedVoice {
  final String artist;
  final String price;
  final String description;

  RecommendedVoice({
    required this.artist,
    required this.price,
    required this.description,
  });

  static List<RecommendedVoice> recommendedVoices = [
    RecommendedVoice(
      artist: 'Voice Artist',
      price: ' 4.99',
      description: 'A calm and soothing voice for your journeys.',
    ),
    RecommendedVoice(
      artist: 'Voice Artist',
      price: ' 2.99',
      description: 'Energetic and clear, perfect for city navigation.',
    ),
    RecommendedVoice(
      artist: 'Voice Artist',
      price: ' 6.99',
      description: 'A fun and adventurous voice.',
    ),
  ];
}
