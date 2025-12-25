import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// Repository provider
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

/// Filter state for job listings
class JobFilters {
  final String searchQuery;
  final JobType? type;
  final WorkLocation? workLocation;
  final ExperienceLevel? experienceLevel;

  const JobFilters({
    this.searchQuery = '',
    this.type,
    this.workLocation,
    this.experienceLevel,
  });

  JobFilters copyWith({
    String? searchQuery,
    JobType? type,
    WorkLocation? workLocation,
    ExperienceLevel? experienceLevel,
    bool clearType = false,
    bool clearWorkLocation = false,
    bool clearExperienceLevel = false,
  }) {
    return JobFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      type: clearType ? null : (type ?? this.type),
      workLocation: clearWorkLocation ? null : (workLocation ?? this.workLocation),
      experienceLevel: clearExperienceLevel ? null : (experienceLevel ?? this.experienceLevel),
    );
  }

  bool get hasActiveFilters =>
      type != null || workLocation != null || experienceLevel != null;

  int get activeFilterCount {
    int count = 0;
    if (type != null) count++;
    if (workLocation != null) count++;
    if (experienceLevel != null) count++;
    return count;
  }
}

/// Filter state provider
final jobFiltersProvider = StateNotifierProvider<JobFiltersNotifier, JobFilters>((ref) {
  return JobFiltersNotifier();
});

class JobFiltersNotifier extends StateNotifier<JobFilters> {
  JobFiltersNotifier() : super(const JobFilters());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setType(JobType? type) {
    if (state.type == type) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(type: type);
    }
  }

  void setWorkLocation(WorkLocation? location) {
    if (state.workLocation == location) {
      state = state.copyWith(clearWorkLocation: true);
    } else {
      state = state.copyWith(workLocation: location);
    }
  }

  void setExperienceLevel(ExperienceLevel? level) {
    if (state.experienceLevel == level) {
      state = state.copyWith(clearExperienceLevel: true);
    } else {
      state = state.copyWith(experienceLevel: level);
    }
  }

  void clearFilters() {
    state = JobFilters(searchQuery: state.searchQuery);
  }

  void clearAll() {
    state = const JobFilters();
  }
}

/// Jobs list provider - fetches jobs based on current filters
final jobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final repository = ref.watch(jobRepositoryProvider);
  final filters = ref.watch(jobFiltersProvider);

  final result = await repository.getJobs(
    searchQuery: filters.searchQuery.isEmpty ? null : filters.searchQuery,
    type: filters.type,
    workLocation: filters.workLocation,
    experienceLevel: filters.experienceLevel,
  );

  return switch (result) {
    Success(data: final jobs) => jobs,
    Failure(message: final msg) => throw Exception(msg),
  };
});

/// Single job provider
final jobDetailProvider = FutureProvider.autoDispose.family<Job, String>((ref, id) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobById(id);

  return switch (result) {
    Success(data: final job) => job,
    Failure(message: final msg) => throw Exception(msg),
  };
});

/// Bookmarked jobs state (local only for demo)
final bookmarkedJobsProvider = StateNotifierProvider<BookmarkedJobsNotifier, Set<String>>((ref) {
  return BookmarkedJobsNotifier();
});

class BookmarkedJobsNotifier extends StateNotifier<Set<String>> {
  BookmarkedJobsNotifier() : super({});

  void toggle(String jobId) {
    if (state.contains(jobId)) {
      state = Set.from(state)..remove(jobId);
    } else {
      state = Set.from(state)..add(jobId);
    }
  }

  bool isBookmarked(String jobId) => state.contains(jobId);
}
