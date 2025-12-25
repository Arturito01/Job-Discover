import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/job_list_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../storage/settings_provider.dart';
import '../widgets/app_shell.dart';

/// App route paths
abstract final class AppRoutes {
  // Auth routes
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';

  // Onboarding
  static const onboarding = '/onboarding';

  // Main routes
  static const jobs = '/';
  static const jobDetail = '/job/:id';
  static const profile = '/profile';
  static const settings = '/settings';

  static String jobDetailPath(String id) => '/job/$id';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final settings = ref.watch(settingsProvider);

  return GoRouter(
    initialLocation: AppRoutes.jobs,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Show onboarding first time
      if (!settings.hasSeenOnboarding && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      // If not authenticated and not on auth route, redirect to login
      // Commented out to allow browsing without auth for demo
      // if (!isAuthenticated && !isOnAuthRoute && !isOnboarding) {
      //   return AppRoutes.login;
      // }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isOnAuthRoute) {
        return AppRoutes.jobs;
      }

      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Main app shell
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.jobs,
            name: 'jobs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JobListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Job detail (outside shell for full-screen experience)
      GoRoute(
        path: AppRoutes.jobDetail,
        name: 'jobDetail',
        pageBuilder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: JobDetailScreen(jobId: jobId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});

/// Legacy router for backward compatibility
final appRouter = GoRouter(
  initialLocation: AppRoutes.jobs,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.jobs,
          name: 'jobs',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: JobListScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.jobDetail,
      name: 'jobDetail',
      pageBuilder: (context, state) {
        final jobId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: JobDetailScreen(jobId: jobId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
