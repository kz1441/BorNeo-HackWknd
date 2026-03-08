import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cash_entry/cash_entry_provider.dart';
import '../selling/selling_provider.dart';
import 'recap_draft_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/confidence_badge.dart';
import '../../shared/widgets/progress_stepper.dart';

class RecapReviewScreen extends ConsumerStatefulWidget {
  const RecapReviewScreen({super.key});

  @override
  ConsumerState<RecapReviewScreen> createState() => _RecapReviewScreenState();
}

class _RecapReviewScreenState extends ConsumerState<RecapReviewScreen> {
  late final TextEditingController _notesController;
  late final ProviderSubscription<RecapDraftState> _recapSubscription;

  @override
  void initState() {
    super.initState();
    final recap = ref.read(recapDraftProvider);
    _notesController = TextEditingController(text: recap.notes);
    _recapSubscription = ref.listenManual<RecapDraftState>(recapDraftProvider, (prev, next) {
      if (next.notes != _notesController.text) {
        _notesController.value = _notesController.value.copyWith(
          text: next.notes,
          selection: TextSelection.collapsed(offset: next.notes.length),
        );
      }

      final prevError = prev?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != prevError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });
  }

  @override
  void dispose() {
    _recapSubscription.close();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellingState = ref.watch(sellingProvider);
    final sellingController = ref.read(sellingProvider.notifier);
    final recap = ref.watch(recapDraftProvider);
    final recapController = ref.read(recapDraftProvider.notifier);
    final cashState = ref.watch(cashEntryProvider);
    final textTheme = Theme.of(context).textTheme;
    final reviewItems = sellingState.menuItems
        .where((item) => (sellingState.countsByMenuItemId[item.id] ?? 0) > 0)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppTheme.warmSurface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.charcoal),
        ),
        title: Text('Review Recap', style: textTheme.headlineMedium?.copyWith(color: AppTheme.charcoal)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.deepForest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const ProgressStepper(currentStep: 3),
            ),
            const SizedBox(height: 20),
            Text('ITEMS DETECTED FROM YOUR RECAP', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
            const SizedBox(height: 12),
            if (reviewItems.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No tapped menu items yet. You can still save the recap with notes and counted cash.',
                    style: textTheme.bodyLarge,
                  ),
                ),
              )
            else
              ...reviewItems.map(
                (item) {
                  final qty = sellingState.countsByMenuItemId[item.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewItemRow(
                      name: item.name,
                      alias: 'Tapped from live quick count',
                      qty: qty,
                      subtotal: 'RM ${(item.price * qty).toStringAsFixed(2)}',
                      badge: recap.isTranscriptConfirmed ? ConfidenceBadgeType.voice : ConfidenceBadgeType.estimated,
                      onDecrement: () => sellingController.updateCount(item, qty - 1),
                      onIncrement: () => sellingController.updateCount(item, qty + 1),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            Text('COUNTED CASH', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('RM', style: AppTheme.mono(size: 20, color: AppTheme.amber, weight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Text((cashState.amount ?? recap.cashSuggestion ?? 0).toStringAsFixed(2), style: AppTheme.mono(size: 28, color: AppTheme.charcoal)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConfidenceBadge(type: cashState.isConfirmed ? ConfidenceBadgeType.confirmed : ConfidenceBadgeType.voice),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Any corrections or notes?', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              onChanged: recapController.setNotes,
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Add notes about corrections, sold out items, or unusual sales...'),
            ),
            const SizedBox(height: 24),
            if (!cashState.isConfirmed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Confirm counted cash first before saving the recap.',
                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.coral, fontWeight: FontWeight.w600),
                ),
              ),
            FilledButton(
              onPressed: recap.isSaving || !cashState.isConfirmed
                  ? null
                  : () async {
                      final ok = await recapController.saveRecap();
                      if (!context.mounted || !ok) return;
                      context.go('/ledger');
                    },
              child: const Text('Save Recap & Continue ->'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItemRow extends StatelessWidget {
  const _ReviewItemRow({
    required this.name,
    required this.alias,
    required this.qty,
    required this.subtotal,
    required this.badge,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String name;
  final String alias;
  final int qty;
  final String subtotal;
  final ConfidenceBadgeType badge;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🍜'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(alias, style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  ConfidenceBadge(type: badge),
                ],
              ),
            ),
            Row(
              children: [
                _QtyButton(icon: Icons.remove_rounded, onTap: onDecrement),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$qty', style: AppTheme.mono(size: 18, color: AppTheme.charcoal)),
                ),
                _QtyButton(icon: Icons.add_rounded, onTap: onIncrement),
              ],
            ),
            const SizedBox(width: 12),
            Text(subtotal, style: AppTheme.mono(size: 16, color: AppTheme.amber)),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.warmSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}