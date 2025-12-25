import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Storage box names
abstract final class StorageBoxes {
  static const String jobs = 'jobs';
  static const String bookmarks = 'bookmarks';
  static const String dismissed = 'dismissed';
  static const String applications = 'applications';
  static const String user = 'user';
  static const String settings = 'settings';
  static const String cache = 'cache';
}

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Hive-based local storage service
class StorageService {
  static bool _initialized = false;

  /// Initialize Hive storage
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Open all boxes
    await Future.wait([
      Hive.openBox<Map>(StorageBoxes.jobs),
      Hive.openBox<String>(StorageBoxes.bookmarks),
      Hive.openBox<String>(StorageBoxes.dismissed),
      Hive.openBox<Map>(StorageBoxes.applications),
      Hive.openBox<Map>(StorageBoxes.user),
      Hive.openBox<dynamic>(StorageBoxes.settings),
      Hive.openBox<Map>(StorageBoxes.cache),
    ]);

    _initialized = true;

    if (kDebugMode) {
      print('Storage: Initialized');
    }
  }

  // Jobs storage
  Box<Map> get _jobsBox => Hive.box<Map>(StorageBoxes.jobs);

  Future<void> saveJobs(List<Map<String, dynamic>> jobs) async {
    await _jobsBox.clear();
    for (final job in jobs) {
      await _jobsBox.put(job['id'], job);
    }
  }

  List<Map<String, dynamic>> getJobs() {
    return _jobsBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Map<String, dynamic>? getJob(String id) {
    final job = _jobsBox.get(id);
    return job != null ? Map<String, dynamic>.from(job) : null;
  }

  // Bookmarks storage
  Box<String> get _bookmarksBox => Hive.box<String>(StorageBoxes.bookmarks);

  Future<void> toggleBookmark(String jobId) async {
    if (_bookmarksBox.containsKey(jobId)) {
      await _bookmarksBox.delete(jobId);
    } else {
      await _bookmarksBox.put(jobId, jobId);
    }
  }

  Set<String> getBookmarks() {
    return _bookmarksBox.values.toSet();
  }

  bool isBookmarked(String jobId) {
    return _bookmarksBox.containsKey(jobId);
  }

  // Dismissed jobs storage
  Box<String> get _dismissedBox => Hive.box<String>(StorageBoxes.dismissed);

  Future<void> dismissJob(String jobId) async {
    await _dismissedBox.put(jobId, jobId);
  }

  Future<void> restoreJob(String jobId) async {
    await _dismissedBox.delete(jobId);
  }

  Future<void> clearDismissed() async {
    await _dismissedBox.clear();
  }

  Set<String> getDismissed() {
    return _dismissedBox.values.toSet();
  }

  bool isDismissed(String jobId) {
    return _dismissedBox.containsKey(jobId);
  }

  // Applications storage
  Box<Map> get _applicationsBox => Hive.box<Map>(StorageBoxes.applications);

  Future<void> saveApplication(Map<String, dynamic> application) async {
    await _applicationsBox.put(application['id'], application);
  }

  List<Map<String, dynamic>> getApplications() {
    return _applicationsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool hasAppliedToJob(String jobId) {
    return _applicationsBox.values.any((app) => app['jobId'] == jobId);
  }

  // User storage
  Box<Map> get _userBox => Hive.box<Map>(StorageBoxes.user);

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _userBox.put('current', user);
  }

  Map<String, dynamic>? getUser() {
    final user = _userBox.get('current');
    return user != null ? Map<String, dynamic>.from(user) : null;
  }

  Future<void> clearUser() async {
    await _userBox.clear();
  }

  // Settings storage
  Box<dynamic> get _settingsBox => Hive.box<dynamic>(StorageBoxes.settings);

  Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Cache storage with TTL
  Box<Map> get _cacheBox => Hive.box<Map>(StorageBoxes.cache);

  Future<void> setCache(
    String key,
    dynamic data, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    await _cacheBox.put(key, {
      'data': data,
      'expiry': DateTime.now().add(ttl).millisecondsSinceEpoch,
    });
  }

  T? getCache<T>(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;

    final expiry = DateTime.fromMillisecondsSinceEpoch(cached['expiry'] as int);
    if (DateTime.now().isAfter(expiry)) {
      _cacheBox.delete(key);
      return null;
    }

    return cached['data'] as T?;
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // Clear all storage
  Future<void> clearAll() async {
    await Future.wait([
      _jobsBox.clear(),
      _bookmarksBox.clear(),
      _dismissedBox.clear(),
      _applicationsBox.clear(),
      _userBox.clear(),
      _cacheBox.clear(),
    ]);
  }
}
