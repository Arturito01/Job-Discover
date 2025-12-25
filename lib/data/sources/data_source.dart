import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

/// Abstract data source interface
abstract class DataSource {
  Future<List<Company>> getCompanies();
  Future<List<Job>> getJobs();
  Future<Job?> getJobById(String id);
  Future<User?> getCurrentUser();
}

/// Local JSON file data source - loads from assets
class LocalDataSource implements DataSource {
  Map<String, Company>? _companiesCache;
  List<Job>? _jobsCache;
  User? _userCache;

  @override
  Future<List<Company>> getCompanies() async {
    if (_companiesCache != null) {
      return _companiesCache!.values.toList();
    }

    final jsonString = await rootBundle.loadString('assets/data/companies.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    final companies = jsonList.map((j) => Company.fromJson(j)).toList();
    _companiesCache = {for (var c in companies) c.id: c};

    return companies;
  }

  Future<Company?> _getCompanyById(String id) async {
    if (_companiesCache == null) {
      await getCompanies();
    }
    return _companiesCache?[id];
  }

  @override
  Future<List<Job>> getJobs() async {
    if (_jobsCache != null) {
      return _jobsCache!;
    }

    // Ensure companies are loaded first
    await getCompanies();

    final jsonString = await rootBundle.loadString('assets/data/jobs.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    final jobs = <Job>[];
    for (final jobJson in jsonList) {
      final companyId = jobJson['companyId'] as String;
      final company = await _getCompanyById(companyId);

      if (company != null) {
        final postedDaysAgo = jobJson['postedDaysAgo'] as int? ?? 0;

        jobs.add(Job(
          id: jobJson['id'] as String,
          title: jobJson['title'] as String,
          company: company,
          description: jobJson['description'] as String,
          requirements: List<String>.from(jobJson['requirements'] as List),
          responsibilities: List<String>.from(jobJson['responsibilities'] as List),
          benefits: List<String>.from(jobJson['benefits'] as List),
          type: JobType.values.firstWhere(
            (e) => e.name == jobJson['type'],
            orElse: () => JobType.fullTime,
          ),
          workLocation: WorkLocation.values.firstWhere(
            (e) => e.name == jobJson['workLocation'],
            orElse: () => WorkLocation.onSite,
          ),
          experienceLevel: ExperienceLevel.values.firstWhere(
            (e) => e.name == jobJson['experienceLevel'],
            orElse: () => ExperienceLevel.mid,
          ),
          salaryRange: jobJson['salaryRange'] as String,
          skills: List<String>.from(jobJson['skills'] as List),
          postedAt: DateTime.now().subtract(Duration(days: postedDaysAgo)),
        ));
      }
    }

    _jobsCache = jobs;
    return jobs;
  }

  @override
  Future<Job?> getJobById(String id) async {
    final jobs = await getJobs();
    try {
      return jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_userCache != null) {
      return _userCache;
    }

    final jsonString = await rootBundle.loadString('assets/data/user.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    _userCache = User.fromJson(jsonMap);
    return _userCache;
  }

  /// Clear cache to force reload
  void clearCache() {
    _companiesCache = null;
    _jobsCache = null;
    _userCache = null;
  }
}

/// Remote API data source - connects to backend
class RemoteDataSource implements DataSource {
  final Dio _dio;
  final String baseUrl;

  RemoteDataSource({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  @override
  Future<List<Company>> getCompanies() async {
    final response = await _dio.get('/companies');
    final List<dynamic> data = response.data;
    return data.map((j) => Company.fromJson(j)).toList();
  }

  @override
  Future<List<Job>> getJobs() async {
    final response = await _dio.get('/jobs');
    final List<dynamic> data = response.data;
    return data.map((j) => Job.fromJson(j)).toList();
  }

  @override
  Future<Job?> getJobById(String id) async {
    try {
      final response = await _dio.get('/jobs/$id');
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get('/user/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }
      rethrow;
    }
  }
}

/// Data source that falls back to local when remote fails
class HybridDataSource implements DataSource {
  final RemoteDataSource remote;
  final LocalDataSource local;

  HybridDataSource({
    required this.remote,
    required this.local,
  });

  @override
  Future<List<Company>> getCompanies() async {
    try {
      return await remote.getCompanies();
    } catch (_) {
      return await local.getCompanies();
    }
  }

  @override
  Future<List<Job>> getJobs() async {
    try {
      return await remote.getJobs();
    } catch (_) {
      return await local.getJobs();
    }
  }

  @override
  Future<Job?> getJobById(String id) async {
    try {
      return await remote.getJobById(id);
    } catch (_) {
      return await local.getJobById(id);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await remote.getCurrentUser();
    } catch (_) {
      return await local.getCurrentUser();
    }
  }
}
