class VoicePack {
  final String artist;
  final String category;
  final String price;
  final double rating;
  final String downloads;
  final String description;
  final bool isPremium;
  final bool isOwned;
  final String elevenLabsVoiceId;

  VoicePack({
    required this.artist,
    required this.category,
    required this.price,
    required this.rating,
    required this.downloads,
    required this.description,
    required this.isPremium,
    required this.isOwned,
    required this.elevenLabsVoiceId,
  });

  static List<VoicePack> allVoicePacks = [
    VoicePack(
      artist: 'Bill',
      category: 'Professional',
      price: '0.00',
      rating: 4.8,
      downloads: '1.5M',
      description: 'A clear, professional male voice for navigation.',
      isPremium: false,
      isOwned: true,
      elevenLabsVoiceId:
          'pNInz6obpgDQGcFmaJgB', // Default ElevenLabs voice (Bill)
    ),
    VoicePack(
      artist: 'Lily',
      category: 'Professional',
      price: '0.00',
      rating: 4.7,
      downloads: '1.2M',
      description: 'A warm, friendly female voice for guidance.',
      isPremium: false,
      isOwned: true,
      elevenLabsVoiceId:
          'Xb7hH8MSUJpSbSDYk0k2', // Default ElevenLabs voice (Lily)
    ),
    VoicePack(
      artist: 'Drew',
      category: 'Professional',
      price: '4.99',
      rating: 4.9,
      downloads: '980K',
      description: 'A confident male voice with a modern tone.',
      isPremium: true,
      isOwned: false,
      elevenLabsVoiceId:
          'N2lVS1w4EtoT3dr4eOWO', // Default ElevenLabs voice (Drew)
    ),
    VoicePack(
      artist: 'Molly',
      category: 'Character',
      price: '5.99',
      rating: 4.8,
      downloads: '850K',
      description: 'A lively, expressive female voice for fun navigation.',
      isPremium: true,
      isOwned: false,
      elevenLabsVoiceId:
          'pqHfZKP75CvOlQylNhV4', // Default ElevenLabs voice (Molly)
    ),
  ];
}
