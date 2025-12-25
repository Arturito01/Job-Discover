import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/sources/data_source.dart';
import '../network/connectivity_service.dart';
import '../storage/storage_service.dart';

/// Sync status for tracking sync operations
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}

/// Sync state with details
class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final int pendingChanges;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.errorMessage,
    this.pendingChanges = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    String? errorMessage,
    int? pendingChanges,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingChanges: pendingChanges ?? this.pendingChanges,
    );
  }

  bool get isOnline => status != SyncStatus.offline;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasError => status == SyncStatus.error;
}

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SyncService(storage: storage);
});

/// Sync state provider
final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);
  return SyncStateNotifier(syncService, isOnline);
});

/// Sync state notifier
class SyncStateNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;
  final bool _isOnline;

  SyncStateNotifier(this._syncService, this._isOnline)
      : super(SyncState(
          status: _isOnline ? SyncStatus.idle : SyncStatus.offline,
          lastSyncedAt: _syncService.lastSyncedAt,
        )) {
    // Auto-sync when coming online
    if (_isOnline && state.lastSyncedAt == null) {
      syncAll();
    }
  }

  Future<void> syncAll() async {
    if (!_isOnline) {
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      await _syncService.syncJobs();
      state = state.copyWith(
        status: SyncStatus.synced,
        lastSyncedAt: DateTime.now(),
        pendingChanges: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void markOffline() {
    state = state.copyWith(status: SyncStatus.offline);
  }

  void markOnline() {
    if (state.status == SyncStatus.offline) {
      state = state.copyWith(status: SyncStatus.idle);
      syncAll();
    }
  }

  void incrementPendingChanges() {
    state = state.copyWith(pendingChanges: state.pendingChanges + 1);
  }
}

/// Service for syncing data between local storage and remote
class SyncService {
  final StorageService _storage;
  final LocalDataSource _localSource;

  DateTime? _lastSyncedAt;

  SyncService({
    required StorageService storage,
    LocalDataSource? localSource,
  })  : _storage = storage,
        _localSource = localSource ?? LocalDataSource();

  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Sync jobs from local source to Hive storage
  Future<void> syncJobs() async {
    try {
      // Load from local JSON source
      final jobs = await _localSource.getJobs();

      // Convert to JSON maps and save to Hive storage
      final jobMaps = jobs.map((job) => _jobToMap(job)).toList();
      await _storage.saveJobs(jobMaps);

      _lastSyncedAt = DateTime.now();

      if (kDebugMode) {
        print('Sync: Successfully synced ${jobs.length} jobs');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync: Failed to sync jobs - $e');
      }
      rethrow;
    }
  }

  /// Get jobs with offline-first strategy
  Future<List<Job>> getJobs({bool forceRefresh = false}) async {
    // Check if we have cached data in Hive
    final cachedJobs = _storage.getJobs();

    if (cachedJobs.isNotEmpty && !forceRefresh) {
      // Return cached data immediately
      return _mapsToJobs(cachedJobs);
    }

    try {
      // Sync from local source to Hive
      await syncJobs();
      final updatedJobs = _storage.getJobs();
      return _mapsToJobs(updatedJobs);
    } catch (e) {
      // Fall back to cached data if sync fails
      if (cachedJobs.isNotEmpty) {
        return _mapsToJobs(cachedJobs);
      }

      // Last resort: load directly from bundled JSON
      return _localSource.getJobs();
    }
  }

  /// Get a single job by ID with offline support
  Future<Job?> getJobById(String id) async {
    // Check Hive storage first
    final cachedJob = _storage.getJob(id);
    if (cachedJob != null) {
      return _mapToJob(cachedJob);
    }

    // Fall back to local source
    return _localSource.getJobById(id);
  }

  /// Sync user data
  Future<void> syncUser() async {
    try {
      final user = await _localSource.getCurrentUser();
      if (user != null) {
        await _storage.saveUser(user.toJson());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync: Failed to sync user - $e');
      }
    }
  }

  /// Get user with offline-first strategy
  Future<User?> getUser() async {
    // Check Hive storage first
    final cachedUser = _storage.getUser();
    if (cachedUser != null) {
      return User.fromJson(cachedUser);
    }

    try {
      await syncUser();
      final updatedUser = _storage.getUser();
      if (updatedUser != null) {
        return User.fromJson(updatedUser);
      }
    } catch (e) {
      // Fall back to local source
      return _localSource.getCurrentUser();
    }

    return null;
  }

  // Helper: Convert Job to Map for storage
  Map<String, dynamic> _jobToMap(Job job) {
    return {
      'id': job.id,
      'title': job.title,
      'company': job.company.toJson(),
      'description': job.description,
      'requirements': job.requirements,
      'responsibilities': job.responsibilities,
      'benefits': job.benefits,
      'type': job.type.name,
      'workLocation': job.workLocation.name,
      'experienceLevel': job.experienceLevel.name,
      'salaryRange': job.salaryRange,
      'skills': job.skills,
      'postedAt': job.postedAt.toIso8601String(),
      'isBookmarked': job.isBookmarked,
    };
  }

  // Helper: Convert list of maps to Jobs
  List<Job> _mapsToJobs(List<Map<String, dynamic>> maps) {
    return maps.map((m) => _mapToJob(m)).whereType<Job>().toList();
  }

  // Helper: Convert Map to Job
  Job? _mapToJob(Map<String, dynamic> map) {
    try {
      final companyMap = Map<String, dynamic>.from(map['company'] as Map);
      final company = Company.fromJson(companyMap);

      return Job(
        id: map['id'] as String,
        title: map['title'] as String,
        company: company,
        description: map['description'] as String,
        requirements: List<String>.from(map['requirements'] ?? []),
        responsibilities: List<String>.from(map['responsibilities'] ?? []),
        benefits: List<String>.from(map['benefits'] ?? []),
        type: JobType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => JobType.fullTime,
        ),
        workLocation: WorkLocation.values.firstWhere(
          (w) => w.name == map['workLocation'],
          orElse: () => WorkLocation.onSite,
        ),
        experienceLevel: ExperienceLevel.values.firstWhere(
          (e) => e.name == map['experienceLevel'],
          orElse: () => ExperienceLevel.mid,
        ),
        salaryRange: map['salaryRange'] as String,
        skills: List<String>.from(map['skills'] ?? []),
        postedAt: DateTime.parse(map['postedAt'] as String),
        isBookmarked: map['isBookmarked'] as bool? ?? false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Sync: Failed to parse job - $e');
      }
      return null;
    }
  }
}
