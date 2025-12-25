import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Current user provider
final currentUserProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getCurrentUser();

  return switch (result) {
    Success(data: final user) => user,
    Failure(message: final msg) => throw Exception(msg),
  };
});

/// User applications provider
final applicationsProvider = FutureProvider<List<Application>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getApplications();

  return switch (result) {
    Success(data: final apps) => apps,
    Failure(message: final msg) => throw Exception(msg),
  };
});

/// Applied jobs set for quick lookup
final appliedJobIdsProvider = Provider<Set<String>>((ref) {
  final applications = ref.watch(applicationsProvider);

  return applications.when(
    data: (apps) => apps.map((a) => a.job.id).toSet(),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Apply to job action
final applyToJobProvider = FutureProvider.autoDispose.family<Application, String>((ref, jobId) async {
  final jobRepository = ref.read(userRepositoryProvider.select((_) => ref.read(userRepositoryProvider.notifier)));
  // This is a simplified version - in a real app you'd handle this better
  final repository = ref.read(userRepositoryProvider);

  // Get the job first
  final jobRepo = JobRepository();
  final jobResult = await jobRepo.getJobById(jobId);

  if (jobResult is Failure<Job>) {
    throw Exception((jobResult as Failure).message);
  }

  final job = (jobResult as Success<Job>).data;

  final application = Application(
    id: 'a${DateTime.now().millisecondsSinceEpoch}',
    job: job,
    status: ApplicationStatus.pending,
    appliedAt: DateTime.now(),
  );

  final result = await repository.addApplication(application);

  // Invalidate applications to refresh the list
  ref.invalidate(applicationsProvider);

  return switch (result) {
    Success(data: final app) => app,
    Failure(message: final msg) => throw Exception(msg),
  };
});
