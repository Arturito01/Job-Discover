import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/models.dart';

/// Keys for Hive boxes
class StorageKeys {
  static const String bookmarks = 'bookmarks';
  static const String dismissed = 'dismissed';
  static const String applications = 'applications';
  static const String userCache = 'user_cache';
  static const String jobsCache = 'jobs_cache';
}

/// Local storage service using Hive
class LocalStorage {
  static LocalStorage? _instance;
  static LocalStorage get instance => _instance ??= LocalStorage._();

  LocalStorage._();

  late Box<String> _bookmarksBox;
  late Box<String> _dismissedBox;
  late Box<String> _applicationsBox;
  late Box<String> _cacheBox;

  bool _initialized = false;

  /// Initialize Hive boxes
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _bookmarksBox = await Hive.openBox<String>(StorageKeys.bookmarks);
    _dismissedBox = await Hive.openBox<String>(StorageKeys.dismissed);
    _applicationsBox = await Hive.openBox<String>(StorageKeys.applications);
    _cacheBox = await Hive.openBox<String>('cache');

    _initialized = true;
  }

  // ============ Bookmarks ============

  /// Get all bookmarked job IDs
  Set<String> getBookmarkedJobIds() {
    return _bookmarksBox.values.toSet();
  }

  /// Add a job to bookmarks
  Future<void> addBookmark(String jobId) async {
    await _bookmarksBox.put(jobId, jobId);
  }

  /// Remove a job from bookmarks
  Future<void> removeBookmark(String jobId) async {
    await _bookmarksBox.delete(jobId);
  }

  /// Check if job is bookmarked
  bool isBookmarked(String jobId) {
    return _bookmarksBox.containsKey(jobId);
  }

  /// Toggle bookmark status
  Future<bool> toggleBookmark(String jobId) async {
    if (isBookmarked(jobId)) {
      await removeBookmark(jobId);
      return false;
    } else {
      await addBookmark(jobId);
      return true;
    }
  }

  // ============ Dismissed Jobs ============

  /// Get all dismissed job IDs
  Set<String> getDismissedJobIds() {
    return _dismissedBox.values.toSet();
  }

  /// Add a job to dismissed
  Future<void> dismissJob(String jobId) async {
    await _dismissedBox.put(jobId, jobId);
  }

  /// Restore a dismissed job
  Future<void> restoreJob(String jobId) async {
    await _dismissedBox.delete(jobId);
  }

  /// Clear all dismissed jobs
  Future<void> clearDismissed() async {
    await _dismissedBox.clear();
  }

  /// Check if job is dismissed
  bool isDismissed(String jobId) {
    return _dismissedBox.containsKey(jobId);
  }

  // ============ Applications ============

  /// Get all applications
  List<Map<String, dynamic>> getApplications() {
    return _applicationsBox.values.map((json) {
      return jsonDecode(json) as Map<String, dynamic>;
    }).toList();
  }

  /// Save an application
  Future<void> saveApplication(Application application) async {
    final json = {
      'id': application.id,
      'jobId': application.job.id,
      'jobTitle': application.job.title,
      'companyName': application.job.company.name,
      'companyLogo': application.job.company.logoUrl,
      'status': application.status.name,
      'appliedAt': application.appliedAt.toIso8601String(),
    };
    await _applicationsBox.put(application.id, jsonEncode(json));
  }

  /// Update application status
  Future<void> updateApplicationStatus(String id, ApplicationStatus status) async {
    final jsonStr = _applicationsBox.get(id);
    if (jsonStr != null) {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      json['status'] = status.name;
      await _applicationsBox.put(id, jsonEncode(json));
    }
  }

  /// Check if applied to a job
  bool hasAppliedToJob(String jobId) {
    return _applicationsBox.values.any((jsonStr) {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return json['jobId'] == jobId;
    });
  }

  // ============ Cache ============

  /// Cache data with expiry
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    final cacheEntry = {
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
      'ttlSeconds': ttl?.inSeconds,
    };
    await _cacheBox.put(key, jsonEncode(cacheEntry));
  }

  /// Get cached data if not expired
  dynamic getCachedData(String key) {
    final jsonStr = _cacheBox.get(key);
    if (jsonStr == null) return null;

    final cacheEntry = jsonDecode(jsonStr) as Map<String, dynamic>;
    final cachedAt = DateTime.parse(cacheEntry['cachedAt'] as String);
    final ttlSeconds = cacheEntry['ttlSeconds'] as int?;

    if (ttlSeconds != null) {
      final expiry = cachedAt.add(Duration(seconds: ttlSeconds));
      if (DateTime.now().isAfter(expiry)) {
        _cacheBox.delete(key);
        return null;
      }
    }

    return cacheEntry['data'];
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // ============ Clear All ============

  /// Clear all storage
  Future<void> clearAll() async {
    await _bookmarksBox.clear();
    await _dismissedBox.clear();
    await _applicationsBox.clear();
    await _cacheBox.clear();
  }
}
