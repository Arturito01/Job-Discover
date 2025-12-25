# Job Discover

A modern, feature-rich job discovery mobile application built with Flutter. This project demonstrates best practices in Flutter development, including clean architecture, state management, offline-first data handling, and polished UI/UX design.

![Flutter](https://img.shields.io/badge/Flutter-3.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

### Core Functionality
- **Job Discovery** - Browse and search job listings with advanced filters
- **Swipeable Cards** - Tinder-style swipe gestures (right to save, left to dismiss)
- **Job Details** - Comprehensive job information with apply functionality
- **Bookmarks** - Save jobs for later with persistent storage
- **User Profile** - Profile management with completion tracking
- **Settings** - Theme toggle, haptic feedback, and app preferences

### UI/UX Highlights
- **Animated Gradient Header** - Morphing gradient blobs with smooth animations
- **Custom Bottom Navigation** - Sliding gradient indicator with bounce effects
- **Skeleton Loading** - Staggered shimmer animations for loading states
- **Confetti Celebration** - Celebration effect when applying to jobs
- **Profile Completion Ring** - Circular progress with gradient and glow effect
- **Offline Indicator** - Visual feedback when device is offline

### Technical Features
- **Offline-First Architecture** - Data persists and works without internet
- **Local Storage** - Hive database for bookmarks, dismissed jobs, and cache
- **API Ready** - Data source abstraction ready for backend integration
- **Internationalization** - Multi-language support (English, Spanish)
- **Dark Mode** - Full dark theme support
- **Responsive Design** - Adapts to different screen sizes

## Tech Stack

### Framework & Language
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.2+ | Cross-platform UI framework |
| Dart | 3.2+ | Programming language |

### State Management
| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | Reactive state management |
| `riverpod_annotation` | Code generation for providers |

### Navigation
| Package | Purpose |
|---------|---------|
| `go_router` | Declarative routing with deep linking |

### Networking
| Package | Purpose |
|---------|---------|
| `dio` | HTTP client for API calls |
| `connectivity_plus` | Network connectivity detection |

### Local Storage
| Package | Purpose |
|---------|---------|
| `hive_flutter` | Fast NoSQL database |
| `flutter_secure_storage` | Encrypted storage for sensitive data |

### UI & Animations
| Package | Purpose |
|---------|---------|
| `flutter_animate` | Declarative animations |
| `shimmer` | Skeleton loading effects |
| `confetti` | Celebration animations |
| `cached_network_image` | Image caching |
| `flutter_svg` | SVG rendering |

### Utilities
| Package | Purpose |
|---------|---------|
| `intl` | Internationalization & formatting |
| `vibration` | Haptic feedback |
| `pinput` | PIN/OTP input fields |

## Architecture

The project follows **Clean Architecture** principles with a feature-first folder structure:

```
lib/
├── core/                    # Shared infrastructure
│   ├── network/            # API client, interceptors, connectivity
│   ├── router/             # App routing configuration
│   ├── services/           # Sync service, background tasks
│   ├── storage/            # Hive storage, settings
│   ├── theme/              # Colors, typography, spacing
│   └── widgets/            # Reusable UI components
│
├── data/                    # Data layer
│   ├── models/             # Domain models (Job, Company, User)
│   ├── repositories/       # Data repositories
│   └── sources/            # Data sources (Local, Remote, Hybrid)
│
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   │   ├── data/          # Auth service
│   │   ├── presentation/  # Screens & widgets
│   │   └── providers/     # Auth state
│   │
│   ├── jobs/               # Job listings
│   │   ├── presentation/  # Screens & widgets
│   │   └── providers/     # Job state & filters
│   │
│   ├── profile/            # User profile
│   │   ├── presentation/  # Screens & widgets
│   │   └── providers/     # Profile state
│   │
│   ├── onboarding/         # Onboarding flow
│   └── settings/           # App settings
│
├── l10n/                    # Localization files
└── main.dart               # App entry point
```

### Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                 │
│  (Screens, Widgets, User Interactions)                          │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     State Management                             │
│  (Riverpod Providers, StateNotifiers)                           │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Repository Layer                            │
│  (JobRepository, UserRepository)                                 │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Data Sources                                │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐        │
│  │ LocalSource │  │ RemoteSource │  │  HybridSource   │        │
│  │ (JSON/Hive) │  │   (API)      │  │ (Fallback)      │        │
│  └─────────────┘  └──────────────┘  └─────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### Offline-First Strategy

```
1. Check Hive cache for data
2. If cache exists → Return cached data
3. If online → Sync from source, update cache
4. If offline → Use cached data or bundled JSON
5. Background sync when connection restored
```

## Getting Started

### Prerequisites
- Flutter SDK 3.2 or higher
- Dart SDK 3.2 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/job-discover.git
   cd job-discover
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (for Riverpod)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Project Structure Details

### Core Widgets

| Widget | Description |
|--------|-------------|
| `SwipeableCard` | Tinder-style swipe gestures with visual feedback |
| `AnimatedGradientHeader` | Morphing gradient blobs background |
| `ProfileCompletionRing` | Circular progress with gradient stroke |
| `OfflineBanner` | Shows when device loses connectivity |
| `JobsLoadingSkeleton` | Staggered shimmer loading animation |

### Providers

| Provider | Type | Description |
|----------|------|-------------|
| `jobsProvider` | FutureProvider | Fetches job listings |
| `jobFiltersProvider` | StateNotifier | Manages search & filters |
| `bookmarkedJobsProvider` | StateNotifier | Persisted bookmarks |
| `dismissedJobsProvider` | StateNotifier | Persisted dismissed jobs |
| `syncStateProvider` | StateNotifier | Sync status tracking |
| `connectivityProvider` | StreamProvider | Network status |

### Data Models

```dart
// Job listing
class Job {
  final String id;
  final String title;
  final Company company;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final List<String> benefits;
  final JobType type;           // fullTime, partTime, contract, internship
  final WorkLocation workLocation;  // remote, hybrid, onSite
  final ExperienceLevel experienceLevel;
  final String salaryRange;
  final List<String> skills;
  final DateTime postedAt;
}

// Company information
class Company {
  final String id;
  final String name;
  final String logoUrl;
  final String industry;
  final String size;
  final String location;
  final String about;
  final String website;
}

// User profile
class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String title;
  final String location;
  final String bio;
  final List<String> skills;
  final String resumeUrl;
}
```

## Customization

### Adding a Backend API

Update `RemoteDataSource` in `lib/data/sources/data_source.dart`:

```dart
final remoteSource = RemoteDataSource(
  baseUrl: 'https://your-api.com/api/v1',
);
```

### Theming

Modify colors in `lib/core/theme/app_colors.dart`:

```dart
abstract final class AppColors {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF7C3AED);
  // ... customize colors
}
```

### Adding New Languages

1. Add ARB file in `assets/l10n/app_xx.arb`
2. Run `flutter gen-l10n`
3. Import in `lib/l10n/app_localizations.dart`

## Screenshots

| Home | Job Details | Profile |
|------|-------------|---------|
| ![Home](screenshots/home.png) | ![Details](screenshots/details.png) | ![Profile](screenshots/profile.png) |

| Swipe | Filters | Settings |
|-------|---------|----------|
| ![Swipe](screenshots/swipe.png) | ![Filters](screenshots/filters.png) | ![Settings](screenshots/settings.png) |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Riverpod](https://riverpod.dev/) - State management
- [Hive](https://docs.hivedb.dev/) - Local database
- [Material Design 3](https://m3.material.io/) - Design system

---

**Built with Flutter**
