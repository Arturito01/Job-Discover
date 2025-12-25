import 'company.dart';

/// Job type enumeration
enum JobType {
  fullTime('Full-time'),
  partTime('Part-time'),
  contract('Contract'),
  internship('Internship');

  final String label;
  const JobType(this.label);
}

/// Work location type
enum WorkLocation {
  remote('Remote'),
  hybrid('Hybrid'),
  onSite('On-site');

  final String label;
  const WorkLocation(this.label);
}

/// Experience level
enum ExperienceLevel {
  entry('Entry Level'),
  mid('Mid Level'),
  senior('Senior'),
  lead('Lead'),
  executive('Executive');

  final String label;
  const ExperienceLevel(this.label);
}

/// Job model representing a job listing
class Job {
  final String id;
  final String title;
  final Company company;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final List<String> benefits;
  final JobType type;
  final WorkLocation workLocation;
  final ExperienceLevel experienceLevel;
  final String salaryRange;
  final List<String> skills;
  final DateTime postedAt;
  final bool isBookmarked;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.benefits,
    required this.type,
    required this.workLocation,
    required this.experienceLevel,
    required this.salaryRange,
    required this.skills,
    required this.postedAt,
    this.isBookmarked = false,
  });

  /// Returns relative time since posting (e.g., "2 days ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  Job copyWith({
    String? id,
    String? title,
    Company? company,
    String? description,
    List<String>? requirements,
    List<String>? responsibilities,
    List<String>? benefits,
    JobType? type,
    WorkLocation? workLocation,
    ExperienceLevel? experienceLevel,
    String? salaryRange,
    List<String>? skills,
    DateTime? postedAt,
    bool? isBookmarked,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      benefits: benefits ?? this.benefits,
      type: type ?? this.type,
      workLocation: workLocation ?? this.workLocation,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryRange: salaryRange ?? this.salaryRange,
      skills: skills ?? this.skills,
      postedAt: postedAt ?? this.postedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      description: json['description'] as String,
      requirements: List<String>.from(json['requirements'] as List),
      responsibilities: List<String>.from(json['responsibilities'] as List),
      benefits: List<String>.from(json['benefits'] as List),
      type: JobType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => JobType.fullTime,
      ),
      workLocation: WorkLocation.values.firstWhere(
        (e) => e.name == json['workLocation'],
        orElse: () => WorkLocation.onSite,
      ),
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == json['experienceLevel'],
        orElse: () => ExperienceLevel.mid,
      ),
      salaryRange: json['salaryRange'] as String,
      skills: List<String>.from(json['skills'] as List),
      postedAt: DateTime.parse(json['postedAt'] as String),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }
}
