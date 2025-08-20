import 'dart:typed_data';
#Comment
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? location;
  final String? bio;
  final String? audioUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.location,
    this.bio,
    this.audioUrl,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      location: data['location'],
      bio: data['bio'],
      audioUrl: data['audioUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'location': location,
      'bio': bio,
      'audioUrl': audioUrl,
    };
  }
}
