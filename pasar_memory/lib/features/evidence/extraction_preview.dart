import 'package:flutter/material.dart';

import 'evidence_provider.dart';

class ExtractionPreview extends StatefulWidget {
  const ExtractionPreview({
    super.key,
    required this.fileId,
    required this.status,
    required this.result,
    required this.onAmountChanged,
  });

  final String fileId;
  final EvidenceProcessingStatus status;
  final EvidenceFileResult? result;
  final void Function(String fileId, String amountId, double nextAmount) onAmountChanged;

  @override
  State<ExtractionPreview> createState() => _ExtractionPreviewState();
}

class _ExtractionPreviewState extends State<ExtractionPreview> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didUpdateWidget(covariant ExtractionPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != widget.result) {
      _syncControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  void _syncControllers() {
    final amounts = widget.result?.amounts ?? const <ExtractedAmount>[];
    final liveIds = amounts.map((e) => e.id).toSet();

    final toRemove = _controllers.keys.where((k) => !liveIds.contains(k)).toList();
    for (final k in toRemove) {
      _controllers.remove(k)?.dispose();
    }

    for (final a in amounts) {
      _controllers.putIfAbsent(a.id, () => TextEditingController(text: a.amount.toStringAsFixed(2)));
      _controllers[a.id]!.text = a.amount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    if (widget.status == EvidenceProcessingStatus.processing) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: LinearProgressIndicator(),
      );
    }

    if (widget.status == EvidenceProcessingStatus.error) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result?.errorMessage ?? 'Needs clearer image',
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final amounts = result?.amounts ?? const <ExtractedAmount>[];
    if (amounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.status == EvidenceProcessingStatus.done
                        ? 'No amounts extracted. You can still proceed and reconcile manually.'
                        : 'Tap Extract to parse amounts.',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _syncControllers();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Extraction preview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...amounts.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[a.id],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount (RM)',
                            helperText: a.trustLabel,
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v.trim());
                            if (parsed != null) {
                              widget.onAmountChanged(widget.fileId, a.id, parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 40,
                        child: FilledButton.tonal(
                          onPressed: () {
                            _controllers[a.id]?.text = a.amount.toStringAsFixed(2);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Edit if needed. Corrections improve matching later.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
