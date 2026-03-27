import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import '../topics/topic_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final topicsAsync = ref.watch(topicListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Agent'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(topicListProvider.notifier).fetchTopics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner
              _WelcomeBanner(name: auth.user?.displayName ?? 'there'),
              const SizedBox(height: 24),

              // Stats row
              topicsAsync.when(
                data: (topics) {
                  final total = topics.length;
                  final weak =
                      topics.where((t) => t.strengthScore < 0.4).length;
                  final avgStr = total == 0
                      ? 0.0
                      : topics
                              .map((t) => t.strengthScore)
                              .reduce((a, b) => a + b) /
                          total;
                  return _StatsRow(
                      total: total, weak: weak, avgStrength: avgStr);
                },
                loading: () => const _StatsRowSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),

              // Quick actions
              Text('Quick Actions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _QuickActions(topicsAsync: topicsAsync),
              const SizedBox(height: 28),

              // Recent topics preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Topics',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.go('/topics'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              topicsAsync.when(
                data: (topics) {
                  if (topics.isEmpty) {
                    return _EmptyTopicsCard(
                        onAdd: () => context.go('/topics'));
                  }
                  final preview = topics.take(3).toList();
                  return Column(
                    children: preview
                        .map((t) => _TopicPreviewTile(
                              title: t.title,
                              strength: t.strengthScore,
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Failed to load topics: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Welcome Banner ────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, $name 👋',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Keep up the learning momentum!',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow(
      {required this.total,
      required this.weak,
      required this.avgStrength});

  final int total;
  final int weak;
  final double avgStrength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'Topics', value: '$total', icon: Icons.book_outlined)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'Need Review',
                value: '$weak',
                icon: Icons.warning_amber_rounded,
                valueColor: weak > 0 ? Colors.orange : null)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'Avg Strength',
                value: '${(avgStrength * 100).round()}%',
                icon: Icons.trending_up_rounded,
                valueColor: _strengthColor(avgStrength))),
      ],
    );
  }

  Color? _strengthColor(double s) {
    if (s >= 0.7) return Colors.green;
    if (s >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      this.valueColor});

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
          3,
          (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.topicsAsync});
  final AsyncValue topicsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.add_circle_outline,
            label: 'Add Topic',
            color: Colors.blue,
            onTap: () => context.go('/topics'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.playlist_add_check_rounded,
            label: 'Review All',
            color: Colors.green,
            onTap: () => context.go('/topics'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.bar_chart_rounded,
            label: 'Progress',
            color: Colors.purple,
            onTap: () => context.go('/topics'),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Topic Preview ─────────────────────────────────────────────────────────────

class _TopicPreviewTile extends StatelessWidget {
  const _TopicPreviewTile(
      {required this.title, required this.strength});

  final String title;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final color = strength >= 0.7
        ? Colors.green
        : strength >= 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(strength * 100).round()}%',
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTopicsCard extends StatelessWidget {
  const _EmptyTopicsCard({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.book_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No topics yet',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add your first topic'),
          ),
        ],
      ),
    );
  }
}
