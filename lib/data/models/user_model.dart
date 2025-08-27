
class UserModel {
  final String id;
  // Multilingual name
  final String name_en;
  final String? name_hi;
  final String? name_kn;
  final String email;
  // Multilingual location
  final String? location_en;
  final String? location_hi;
  final String? location_kn;
  // Multilingual bio
  final String? bio_en;
  final String? bio_hi;
  final String? bio_kn;
  // Optional audio intro
  final String? audioUrl;

  UserModel({
    required this.id,
    required this.name_en,
    this.name_hi,
    this.name_kn,
    required this.email,
    this.location_en,
    this.location_hi,
    this.location_kn,
    this.bio_en,
    this.bio_hi,
    this.bio_kn,
    this.audioUrl,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name_en: data['name_en'] ?? data['name'] ?? '',
      name_hi: data['name_hi'],
      name_kn: data['name_kn'],
      email: data['email'] ?? '',
      location_en: data['location_en'] ?? data['location'],
      location_hi: data['location_hi'],
      location_kn: data['location_kn'],
      bio_en: data['bio_en'] ?? data['bio'],
      bio_hi: data['bio_hi'],
      bio_kn: data['bio_kn'],
      audioUrl: data['audioUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name_en': name_en,
      if (name_hi != null) 'name_hi': name_hi,
      if (name_kn != null) 'name_kn': name_kn,
      'email': email,
      if (location_en != null) 'location_en': location_en,
      if (location_hi != null) 'location_hi': location_hi,
      if (location_kn != null) 'location_kn': location_kn,
      if (bio_en != null) 'bio_en': bio_en,
      if (bio_hi != null) 'bio_hi': bio_hi,
      if (bio_kn != null) 'bio_kn': bio_kn,
      'audioUrl': audioUrl,
    };
  }
}
