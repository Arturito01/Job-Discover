import '../mock/mock_data.dart';
import '../models/models.dart';

/// Result wrapper for async operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

/// Repository for job-related data operations
/// In a real app, this would call an API service
class JobRepository {
  /// Simulated network delay for realistic loading states
  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Fetch all jobs with optional filters
  Future<Result<List<Job>>> getJobs({
    String? searchQuery,
    JobType? type,
    WorkLocation? workLocation,
    ExperienceLevel? experienceLevel,
  }) async {
    try {
      await _simulateNetwork();

      var jobs = List<Job>.from(MockData.jobs);

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        jobs = jobs.where((job) {
          return job.title.toLowerCase().contains(query) ||
              job.company.name.toLowerCase().contains(query) ||
              job.skills.any((s) => s.toLowerCase().contains(query));
        }).toList();
      }

      if (type != null) {
        jobs = jobs.where((job) => job.type == type).toList();
      }

      if (workLocation != null) {
        jobs = jobs.where((job) => job.workLocation == workLocation).toList();
      }

      if (experienceLevel != null) {
        jobs = jobs.where((job) => job.experienceLevel == experienceLevel).toList();
      }

      // Sort by posted date (newest first)
      jobs.sort((a, b) => b.postedAt.compareTo(a.postedAt));

      return Success(jobs);
    } catch (e) {
      return Failure('Failed to fetch jobs: ${e.toString()}');
    }
  }

  /// Get a single job by ID
  Future<Result<Job>> getJobById(String id) async {
    try {
      await _simulateNetwork();

      final job = MockData.jobs.firstWhere(
        (j) => j.id == id,
        orElse: () => throw Exception('Job not found'),
      );

      return Success(job);
    } catch (e) {
      return Failure('Failed to fetch job: ${e.toString()}');
    }
  }

  /// Apply to a job
  Future<Result<Application>> applyToJob(String jobId) async {
    try {
      await _simulateNetwork();

      final job = MockData.jobs.firstWhere(
        (j) => j.id == jobId,
        orElse: () => throw Exception('Job not found'),
      );

      final application = Application(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        job: job,
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
      );

      return Success(application);
    } catch (e) {
      return Failure('Failed to apply: ${e.toString()}');
    }
  }

  /// Toggle bookmark status
  Future<Result<Job>> toggleBookmark(String jobId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final jobIndex = MockData.jobs.indexWhere((j) => j.id == jobId);
      if (jobIndex == -1) {
        return const Failure('Job not found');
      }

      final job = MockData.jobs[jobIndex];
      final updatedJob = job.copyWith(isBookmarked: !job.isBookmarked);

      return Success(updatedJob);
    } catch (e) {
      return Failure('Failed to update bookmark: ${e.toString()}');
    }
  }
}
