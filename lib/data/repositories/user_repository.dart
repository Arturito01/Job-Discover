import '../mock/mock_data.dart';
import '../models/models.dart';
import 'job_repository.dart';

/// Repository for user-related data operations
class UserRepository {
  final List<Application> _applications = List.from(MockData.applications);

  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get current user profile
  Future<Result<User>> getCurrentUser() async {
    try {
      await _simulateNetwork();
      return const Success(MockData.user);
    } catch (e) {
      return Failure('Failed to fetch user: ${e.toString()}');
    }
  }

  /// Get user's job applications
  Future<Result<List<Application>>> getApplications() async {
    try {
      await _simulateNetwork();
      // Sort by applied date (newest first)
      final sorted = List<Application>.from(_applications)
        ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return Success(sorted);
    } catch (e) {
      return Failure('Failed to fetch applications: ${e.toString()}');
    }
  }

  /// Add a new application
  Future<Result<Application>> addApplication(Application application) async {
    try {
      await _simulateNetwork();
      _applications.add(application);
      return Success(application);
    } catch (e) {
      return Failure('Failed to add application: ${e.toString()}');
    }
  }

  /// Check if user has applied to a job
  bool hasAppliedToJob(String jobId) {
    return _applications.any((app) => app.job.id == jobId);
  }
}
