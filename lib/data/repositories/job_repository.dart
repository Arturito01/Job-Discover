import '../models/models.dart';
import '../sources/data_source.dart';

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
/// Uses DataSource abstraction for flexibility between local/remote data
class JobRepository {
  final DataSource _dataSource;

  JobRepository({DataSource? dataSource})
      : _dataSource = dataSource ?? LocalDataSource();

  /// Simulated network delay for realistic loading states (only for local source)
  Future<void> _simulateNetwork() async {
    if (_dataSource is LocalDataSource) {
      await Future.delayed(const Duration(milliseconds: 600));
    }
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

      var jobs = await _dataSource.getJobs();

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

      final job = await _dataSource.getJobById(id);

      if (job == null) {
        return const Failure('Job not found');
      }

      return Success(job);
    } catch (e) {
      return Failure('Failed to fetch job: ${e.toString()}');
    }
  }

  /// Apply to a job
  Future<Result<Application>> applyToJob(String jobId) async {
    try {
      await _simulateNetwork();

      final job = await _dataSource.getJobById(jobId);

      if (job == null) {
        return const Failure('Job not found');
      }

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
      await Future.delayed(const Duration(milliseconds: 200));

      final job = await _dataSource.getJobById(jobId);

      if (job == null) {
        return const Failure('Job not found');
      }

      final updatedJob = job.copyWith(isBookmarked: !job.isBookmarked);
      return Success(updatedJob);
    } catch (e) {
      return Failure('Failed to update bookmark: ${e.toString()}');
    }
  }
}
