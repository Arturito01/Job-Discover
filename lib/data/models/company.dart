/// Company model representing employer information
class Company {
  final String id;
  final String name;
  final String logoUrl;
  final String industry;
  final String size;
  final String location;
  final String about;
  final String website;

  const Company({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.industry,
    required this.size,
    required this.location,
    required this.about,
    required this.website,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      industry: json['industry'] as String,
      size: json['size'] as String,
      location: json['location'] as String,
      about: json['about'] as String,
      website: json['website'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'industry': industry,
      'size': size,
      'location': location,
      'about': about,
      'website': website,
    };
  }
}
