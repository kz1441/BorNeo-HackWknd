import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/confidence_badge.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/progress_stepper.dart';
import 'evidence_provider.dart';
import 'extraction_preview.dart';

class EvidenceUploadScreen extends ConsumerStatefulWidget {
  const EvidenceUploadScreen({
    super.key,
    this.initialSharedPaths,
  });

  /// Pass in paths received from a share-sheet / intent handler.
  /// Dev 1 can wire this through the router (e.g. `extra`).
  final List<String>? initialSharedPaths;

  @override
  ConsumerState<EvidenceUploadScreen> createState() => _EvidenceUploadScreenState();
}

class _EvidenceUploadScreenState extends ConsumerState<EvidenceUploadScreen> {
  final _picker = ImagePicker();
  bool _didIngestInitialShared = false;
  late final ProviderSubscription<EvidenceState> _evidenceSubscription;

  @override
  void initState() {
    super.initState();

    _evidenceSubscription = ref.listenManual<EvidenceState>(evidenceProvider, (prev, next) {
      final prevWarn = prev?.warningMessage;
      final nextWarn = next.warningMessage;
      if (nextWarn != null && nextWarn != prevWarn) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(nextWarn),
              action: next.pendingDuplicateAdds.isNotEmpty
                  ? SnackBarAction(
                      label: 'Add anyway',
                      onPressed: () {
                        ref.read(evidenceProvider.notifier).addDuplicatesAnyway();
                      },
                    )
                  : null,
            ),
          );
      }

      if (next.pendingDuplicateAdds.isNotEmpty && (prev?.pendingDuplicateAdds.isEmpty ?? true)) {
        _showDuplicateDialog();
      }
    });
  }

  @override
  void dispose() {
    _evidenceSubscription.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didIngestInitialShared) return;

    final shared = widget.initialSharedPaths;
    if (shared != null && shared.isNotEmpty) {
      _didIngestInitialShared = true;
      ref.read(evidenceProvider.notifier).ingestSharedPaths(shared);
    }
  }

  Future<void> _showDuplicateDialog() async {
    final state = ref.read(evidenceProvider);
    if (state.pendingDuplicateAdds.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Duplicate detected'),
          content: Text(
            '${state.pendingDuplicateAdds.length} file(s) look like duplicates. Add anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(evidenceProvider.notifier).discardDuplicates();
                Navigator.of(context).pop();
              },
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(evidenceProvider.notifier).addDuplicatesAnyway();
                Navigator.of(context).pop();
              },
              child: const Text('Add anyway'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final picks = await _picker.pickMultiImage();
      if (!mounted) return;
      if (picks.isEmpty) return;
      await ref.read(evidenceProvider.notifier).addFromGallery(picks);
    } catch (_) {
      final single = await _picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (single == null) return;
      await ref.read(evidenceProvider.notifier).addFromGallery([single]);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;

    await ref.read(evidenceProvider.notifier).addFromFilePicker(result.files);
  }

  bool _isLikelyImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  Widget _thumbnail(EvidenceIngestedFile f) {
    final isImage = _isLikelyImage(f.name);

    if (!isImage) {
      return const CircleAvatar(child: Icon(Icons.description_outlined));
    }

    if (f.bytes != null && f.bytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          f.bytes!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    if (!kIsWeb && f.path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(f.path!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const CircleAvatar(child: Icon(Icons.image_not_supported_outlined));
          },
        ),
      );
    }

    return const CircleAvatar(child: Icon(Icons.image_outlined));
  }

  String _sourceLabel(EvidenceSource source) {
    return switch (source) {
      EvidenceSource.screenshot => 'From screenshot',
      EvidenceSource.export => 'From export',
      EvidenceSource.shared => 'From share-sheet',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(evidenceProvider);
    final controller = ref.read(evidenceProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.deepForest, AppTheme.forestGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.softWhite),
                        ),
                        Expanded(
                          child: Text(
                            'Add Payment Evidence',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const ProgressStepper(currentStep: 1),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: const Border(left: BorderSide(color: AppTheme.amber, width: 4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.amber),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Upload your QR payment screenshots or transaction history. We\'ll extract the totals for you.',
                              style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('UPLOAD EVIDENCE', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickFromGallery,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.amber, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, color: AppTheme.amber, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload screenshot or import from gallery',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Accepted: single payment, transaction history, settlement screenshots',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFiles,
                            icon: const Icon(Icons.folder_open_rounded),
                            label: const Text('Import File'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.ios_share_rounded),
                            label: const Text('Share Sheet'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (state.files.isNotEmpty) ...[
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.files.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final file = state.files[index];
                            final status = state.statusById[file.id] ?? EvidenceProcessingStatus.idle;
                            return SizedBox(
                              width: 220,
                              child: _EvidenceCard(
                                file: file,
                                status: status,
                                thumbnail: _thumbnail(file),
                                sourceLabel: _sourceLabel(file.source),
                                onEdit: () => controller.processFile(file.id),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text('EXTRACTED RESULTS', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                    const SizedBox(height: 12),
                    if (state.files.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No evidence uploaded yet. Add your first screenshot to begin reconstruction.',
                            style: textTheme.bodyLarge,
                          ),
                        ),
                      )
                    else
                      ...state.files.map((f) {
                        final status = state.statusById[f.id] ?? EvidenceProcessingStatus.idle;
                        final result = state.resultById[f.id];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      _thumbnail(f),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              f.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            ConfidenceBadge(
                                              type: status == EvidenceProcessingStatus.error
                                                  ? ConfidenceBadgeType.needsReview
                                                  : ConfidenceBadgeType.screenshot,
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => controller.processFile(f.id),
                                        child: const Text('Edit'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ExtractionPreview(
                                    fileId: f.id,
                                    status: status,
                                    result: result,
                                    onAmountChanged: controller.updateExtractedAmount,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () async {
                        await controller.processAllPending();
                        if (!context.mounted) return;
                        context.go('/voice-recap');
                      },
                      child: const Text('Confirm Evidence & Continue ->'),
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
              const AppBottomNav(currentRoute: '/capture'),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
    required this.file,
    required this.status,
    required this.thumbnail,
    required this.sourceLabel,
    required this.onEdit,
  });

  final EvidenceIngestedFile file;
  final EvidenceProcessingStatus status;
  final Widget thumbnail;
  final String sourceLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 48, height: 48, child: thumbnail),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sourceLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('RM --.--', style: AppTheme.mono(size: 24)),
          const SizedBox(height: 10),
          ConfidenceBadge(
            type: status == EvidenceProcessingStatus.error
                ? ConfidenceBadgeType.needsReview
                : ConfidenceBadgeType.screenshot,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(onPressed: onEdit, child: const Text('Edit')),
          ),
        ],
      ),
    );
  }
}
