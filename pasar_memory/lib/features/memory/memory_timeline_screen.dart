import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';

final memoryTimelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final accountId = ref.watch(sessionProvider).accountKey;
  if (accountId.isEmpty) {
    return Future.value(const <Map<String, dynamic>>[]);
  }
  return ref.read(ledgerRepositoryProvider).getRecentLedgers(accountId: accountId);
});

class MemoryTimelineScreen extends ConsumerWidget {
  const MemoryTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgersAsync = ref.watch(memoryTimelineProvider);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        color: AppTheme.deepForest,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Memory', style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite)),
                        ),
                        IconButton(
                          onPressed: () => ref.invalidate(memoryTimelineProvider),
                          icon: const Icon(Icons.refresh_rounded, color: AppTheme.softWhite),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          _FilterChip(label: 'All', active: true),
                          SizedBox(width: 8),
                          _FilterChip(label: 'Saved'),
                          SizedBox(width: 8),
                          _FilterChip(label: 'Recent'),
                          SizedBox(width: 8),
                          _FilterChip(label: 'Confirmed'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ledgersAsync.when(
                      data: (ledgers) {
                        final sevenDayTotal = ledgers.fold<double>(
                          0,
                          (sum, ledger) => sum + ((ledger['totalSales'] as num?)?.toDouble() ?? 0),
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SAVED TOTAL', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                                  const SizedBox(height: 8),
                                  Text('RM ${sevenDayTotal.toStringAsFixed(2)}', style: AppTheme.mono(size: 30, color: AppTheme.amber)),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${ledgers.length} saved day${ledgers.length == 1 ? '' : 's'} in memory',
                                    style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text('RECENT DAYS', style: textTheme.labelMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.5))),
                            const SizedBox(height: 12),
                            if (ledgers.isEmpty)
                              Text(
                                'No saved ledgers yet. Finish one recap and save it to memory.',
                                style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                              )
                            else
                              ...ledgers.map(
                                (ledger) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _DayHistoryCard(
                                    date: _dateLabel(ledger['date']?.toString() ?? ''),
                                    total: 'RM ${((ledger['totalSales'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                                    confirmed: (ledger['isConfirmed'] == 1) || (ledger['isConfirmed'] == true),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => Text(
                        'Could not load your saved memory yet.',
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              const AppBottomNav(currentRoute: '/memory'),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(String rawDate) {
    if (rawDate.isEmpty) return '--/---';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${parsed.day.toString().padLeft(2, '0')}/${months[parsed.month - 1]}';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppTheme.amber : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? AppTheme.amber : AppTheme.softWhite.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: active ? AppTheme.charcoal : AppTheme.softWhite,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DayHistoryCard extends StatelessWidget {
  const _DayHistoryCard({required this.date, required this.total, required this.confirmed});

  final String date;
  final String total;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    final accent = confirmed ? AppTheme.jade : AppTheme.coral;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(width: 4, decoration: BoxDecoration(color: accent, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
            child: Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(total, style: AppTheme.mono(size: 18, color: AppTheme.softWhite)),
                const SizedBox(height: 4),
                Text('Total Sales', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Row(
            children: [
              Icon(confirmed ? Icons.check_circle_rounded : Icons.warning_amber_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.softWhite),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }
}