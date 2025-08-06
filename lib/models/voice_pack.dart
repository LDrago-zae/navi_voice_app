class VoicePack {
  final String artist;
  final String category;
  final String price;
  final double rating;
  final String downloads;
  final String description;
  final bool isPremium;
  final bool isOwned;

  VoicePack({
    required this.artist,
    required this.category,
    required this.price,
    required this.rating,
    required this.downloads,
    required this.description,
    required this.isPremium,
    required this.isOwned,
  });

  static List<VoicePack> allVoicePacks = [
    VoicePack(
      artist: 'Gal Gadot',
      category: 'Celebrity',
      price: '6.99',
      rating: 4.9,
      downloads: '1.2M',
      description: 'Wonder Woman\'s voice for your adventures',
      isPremium: true,
      isOwned: false,
    ),
    VoicePack(
      artist: 'Morgan Freeman',
      category: 'Celebrity',
      price: '7.99',
      rating: 4.8,
      downloads: '980K',
      description: 'The legendary narrator\'s calming voice',
      isPremium: true,
      isOwned: true,
    ),
    VoicePack(
      artist: 'Siri Enhanced',
      category: 'Character',
      price: '3.99',
      rating: 4.7,
      downloads: '2.1M',
      description: 'Enhanced AI assistant voice',
      isPremium: false,
      isOwned: false,
    ),
    VoicePack(
      artist: 'British Navigator',
      category: 'Language',
      price: '2.99',
      rating: 4.6,
      downloads: '1.5M',
      description: 'Proper British accent for navigation',
      isPremium: false,
      isOwned: false,
    ),
    VoicePack(
      artist: 'Ryan Reynolds',
      category: 'Celebrity',
      price: '8.99',
      rating: 4.9,
      downloads: '850K',
      description: 'Witty and entertaining navigation',
      isPremium: true,
      isOwned: false,
    ),
    VoicePack(
      artist: 'JARVIS AI',
      category: 'Character',
      price: '5.99',
      rating: 4.8,
      downloads: '1.8M',
      description: 'Iron Man\'s AI assistant',
      isPremium: false,
      isOwned: false,
    ),
  ];
}
