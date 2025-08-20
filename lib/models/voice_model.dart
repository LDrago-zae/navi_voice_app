class VoiceModel {
  final String id;
  final String name;
  final String? gender;
  final String? description;

  VoiceModel({
    required this.id,
    required this.name,
    this.gender,
    this.description,
  });

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['voice_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      gender: json['labels']?['gender'],
      description: json['description'],
    );
  }
}
