/// User profile model
class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String title;
  final String location;
  final String bio;
  final List<String> skills;
  final String resumeUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.title,
    required this.location,
    required this.bio,
    required this.skills,
    required this.resumeUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      bio: json['bio'] as String,
      skills: List<String>.from(json['skills'] as List),
      resumeUrl: json['resumeUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'title': title,
      'location': location,
      'bio': bio,
      'skills': skills,
      'resumeUrl': resumeUrl,
    };
  }
}
