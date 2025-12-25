import '../models/models.dart';
import '../sources/data_source.dart';
import 'job_repository.dart';

/// Repository for user-related data operations
class UserRepository {
  final DataSource _dataSource;
  final List<Application> _applications = [];

  UserRepository({DataSource? dataSource})
      : _dataSource = dataSource ?? LocalDataSource();

  /// Simulated network delay
  Future<void> _simulateNetwork() async {
    if (_dataSource is LocalDataSource) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Get current user profile
  Future<Result<User>> getCurrentUser() async {
    try {
      await _simulateNetwork();

      final user = await _dataSource.getCurrentUser();

      if (user == null) {
        return const Failure('User not found');
      }

      return Success(user);
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
      await Future.delayed(const Duration(milliseconds: 300));
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
