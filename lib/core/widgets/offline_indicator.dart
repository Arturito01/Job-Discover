import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_service.dart';
import '../services/sync_service.dart';

/// Banner showing offline status
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOnline ? 0 : 28,
      color: Colors.grey.shade800,
      child: isOnline
          ? null
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You\'re offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Sync status indicator for app bar
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildIndicator(context, syncState),
    );
  }

  Widget _buildIndicator(BuildContext context, SyncState state) {
    switch (state.status) {
      case SyncStatus.syncing:
        return SizedBox(
          key: const ValueKey('syncing'),
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );

      case SyncStatus.offline:
        return Icon(
          key: const ValueKey('offline'),
          Icons.cloud_off,
          size: 20,
          color: Colors.grey.shade500,
        );

      case SyncStatus.error:
        return Icon(
          key: const ValueKey('error'),
          Icons.sync_problem,
          size: 20,
          color: Colors.red.shade400,
        );

      case SyncStatus.synced:
        return Icon(
          key: const ValueKey('synced'),
          Icons.cloud_done,
          size: 20,
          color: Colors.green.shade400,
        );

      case SyncStatus.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));
    }
  }
}

/// Pull-to-refresh wrapper with sync integration
class SyncRefreshIndicator extends ConsumerWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;

  const SyncRefreshIndicator({
    super.key,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        final isOnline = ref.read(isOnlineProvider);
        if (isOnline) {
          await ref.read(syncStateProvider.notifier).syncAll();
        }
        await onRefresh?.call();
      },
      child: child,
    );
  }
}

/// Offline-aware data wrapper
class OfflineAwareBuilder<T> extends ConsumerWidget {
  final AsyncValue<T> data;
  final Widget Function(T data) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;
  final Widget Function()? offlineBuilder;

  const OfflineAwareBuilder({
    super.key,
    required this.data,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.offlineBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return data.when(
      data: (value) => builder(value),
      loading: () =>
          loadingBuilder?.call() ??
          const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        if (!isOnline && offlineBuilder != null) {
          return offlineBuilder!();
        }
        return errorBuilder?.call(error, stack) ??
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOnline ? Icons.error_outline : Icons.cloud_off,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isOnline
                          ? 'Something went wrong'
                          : 'You\'re offline',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOnline
                          ? 'Please try again later'
                          : 'Check your connection',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}

/// Last synced timestamp display
class LastSyncedText extends ConsumerWidget {
  const LastSyncedText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    if (syncState.lastSyncedAt == null) {
      return const SizedBox.shrink();
    }

    final timeAgo = _formatTimeAgo(syncState.lastSyncedAt!);

    return Text(
      'Last updated $timeAgo',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
