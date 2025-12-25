# Job Discover - Architecture Overview

A production-ready Flutter job discovery app demonstrating senior-level mobile development practices with modern architecture patterns.

## Project Structure

```
lib/
├── main.dart                           # App entry point with initialization
├── core/                               # Shared infrastructure
│   ├── network/                        # API layer
│   │   ├── api_client.dart            # Dio client configuration
│   │   ├── api_interceptors.dart      # Logging, auth, retry, cache
│   │   └── connectivity_service.dart  # Network monitoring
│   ├── router/                         # Navigation (go_router)
│   │   └── app_router.dart            # Routes with auth guards
│   ├── storage/                        # Local persistence
│   │   ├── storage_service.dart       # Hive-based storage
│   │   └── settings_provider.dart     # App settings state
│   ├── theme/                          # Design system
│   │   ├── app_colors.dart            # Light + Dark palettes
│   │   ├── app_spacing.dart           # 4px grid system
│   │   ├── app_typography.dart        # Type scale
│   │   └── app_theme.dart             # Material 3 themes
│   └── widgets/                        # App-wide widgets
│       └── app_shell.dart             # Bottom navigation shell
├── data/                               # Data layer
│   ├── models/                         # Domain entities
│   │   ├── job.dart
│   │   ├── company.dart
│   │   ├── user.dart
│   │   └── application.dart
│   ├── mock/                           # Mock data
│   │   └── mock_data.dart
│   └── repositories/                   # Data access abstraction
│       ├── job_repository.dart
│       └── user_repository.dart
├── features/                           # Feature modules
│   ├── auth/
│   │   ├── data/auth_service.dart
│   │   ├── providers/auth_provider.dart
│   │   └── presentation/screens/
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── forgot_password_screen.dart
│   ├── jobs/
│   │   ├── providers/job_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── job_list_screen.dart
│   │       │   └── job_detail_screen.dart
│   │       └── widgets/
│   ├── onboarding/
│   │   └── presentation/screens/onboarding_screen.dart
│   ├── profile/
│   │   ├── providers/profile_providers.dart
│   │   └── presentation/screens/profile_screen.dart
│   └── settings/
│       └── presentation/screens/settings_screen.dart
└── l10n/                               # Localization
    ├── app_en.arb
    └── app_es.arb
```

## Key Features Implemented

### Core Infrastructure

| Feature | Implementation | File |
|---------|---------------|------|
| **API Layer** | Dio with interceptors (logging, auth, retry, cache) | `core/network/api_client.dart` |
| **Local Storage** | Hive for offline data, settings, cache | `core/storage/storage_service.dart` |
| **Secure Storage** | flutter_secure_storage for auth tokens | `features/auth/data/auth_service.dart` |
| **Connectivity** | Real-time network monitoring | `core/network/connectivity_service.dart` |

### State Management: Riverpod

**Why Riverpod:**
- Compile-time safety (no runtime provider errors)
- No BuildContext dependency for accessing state
- Built-in caching with `autoDispose`
- Easy testing with provider overrides

**Provider Patterns Used:**
```dart
// Repository provider
final jobRepositoryProvider = Provider<JobRepository>((ref) => JobRepository());

// Async data with auto-refresh
final jobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final filters = ref.watch(jobFiltersProvider);  // Auto-refetch on filter change
  return ref.watch(jobRepositoryProvider).getJobs(filters: filters);
});

// Mutable state
final jobFiltersProvider = StateNotifierProvider<JobFiltersNotifier, JobFilters>(...);
```

### Navigation: go_router

- **Auth-aware routing** with redirect guards
- **ShellRoute** for persistent bottom navigation
- **Custom transitions** (slide, fade)
- **Deep linking** ready

### Theme System

- **Light & Dark themes** with system preference support
- **4px grid spacing** for consistent visual rhythm
- **Semantic color tokens** for badges and states
- **Theme-aware color extensions** for easy access

### Authentication Flow

- **Login/Signup/Forgot Password** screens
- **Secure token storage** with flutter_secure_storage
- **Auth state provider** with loading/error handling
- **Protected routes** via router redirect

### User Experience

| Feature | Description |
|---------|-------------|
| **Pull-to-refresh** | RefreshIndicator on job list |
| **Infinite scroll** | Scroll-based pagination |
| **Loading skeletons** | Shimmer placeholders |
| **Error states** | Retry-able error displays |
| **Haptic feedback** | Configurable vibrations |
| **Onboarding** | First-launch tutorial |

### Animations

- **Staggered list animations** with flutter_animate
- **Hero transitions** for company logos and job titles
- **Micro-interactions** on bookmark buttons
- **Page transitions** (slide/fade)

### Accessibility

- **Semantic labels** on all interactive elements
- **Sufficient color contrast** in both themes
- **Focus management** for keyboard navigation
- **Screen reader support** with proper widget semantics

### Localization

- **Flutter intl** with ARB files
- **English & Spanish** translations
- **Language switcher** in settings
- **Locale-aware formatting**

## Architecture Decisions

### Repository Pattern with Result Type

```dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> { final T data; ... }
class Failure<T> extends Result<T> { final String message; ... }

// Usage
final result = await repository.getJobs();
return switch (result) {
  Success(data: final jobs) => jobs,
  Failure(message: final msg) => throw Exception(msg),
};
```

### API Interceptors

1. **LoggingInterceptor** - Debug request/response logging
2. **AuthInterceptor** - Token injection and 401 handling
3. **RetryInterceptor** - Automatic retry for transient failures
4. **CacheInterceptor** - In-memory caching with TTL

### Storage Architecture

```dart
// Hive boxes for different data types
StorageBoxes.jobs        // Offline job cache
StorageBoxes.bookmarks   // User bookmarks
StorageBoxes.applications // Applied jobs
StorageBoxes.user        // User profile
StorageBoxes.settings    // App preferences
StorageBoxes.cache       // General cache with TTL
```

## Running the Project

```bash
# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on device/emulator
flutter run

# Run with specific theme
flutter run --dart-define=THEME=dark

# Build for production
flutter build apk --release
flutter build ios --release

# Run tests
flutter test
```

## Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Navigation |
| dio | HTTP client |
| hive_flutter | Local storage |
| flutter_secure_storage | Secure credentials |
| connectivity_plus | Network monitoring |
| flutter_animate | Animations |
| shimmer | Loading skeletons |
| cached_network_image | Image caching |
| intl | Localization |

## Testing Strategy

```
test/
├── unit/
│   ├── models/          # Model serialization
│   ├── repositories/    # Repository logic
│   └── providers/       # State management
├── widget/
│   ├── job_card_test.dart
│   ├── filter_sheet_test.dart
│   └── auth_flow_test.dart
└── integration/
    ├── job_search_test.dart
    └── apply_flow_test.dart
```

## Performance Optimizations

- **Image caching** with cached_network_image
- **List item recycling** with ListView.builder
- **Provider auto-dispose** for memory efficiency
- **Lazy loading** for job detail data
- **Shimmer skeletons** for perceived performance

---

Built as a senior-level portfolio project demonstrating:
- Clean architecture with feature-based organization
- Modern state management patterns
- Production-ready infrastructure
- Polished UI/UX with animations and accessibility
- Comprehensive error handling
- Offline-first approach
