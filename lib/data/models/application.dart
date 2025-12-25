import 'job.dart';

/// Application status
enum ApplicationStatus {
  pending('Pending'),
  reviewed('Reviewed'),
  interviewing('Interviewing'),
  offered('Offered'),
  rejected('Rejected');

  final String label;
  const ApplicationStatus(this.label);
}

/// Job application model
class Application {
  final String id;
  final Job job;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const Application({
    required this.id,
    required this.job,
    required this.status,
    required this.appliedAt,
  });

  /// Returns formatted date string
  String get appliedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[appliedAt.month - 1]} ${appliedAt.day}, ${appliedAt.year}';
  }

  Application copyWith({
    String? id,
    Job? job,
    ApplicationStatus? status,
    DateTime? appliedAt,
  }) {
    return Application(
      id: id ?? this.id,
      job: job ?? this.job,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
