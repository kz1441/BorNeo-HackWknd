import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../review/recap_draft_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/progress_stepper.dart';
import '../../shared/widgets/voice_waveform.dart';

class VoiceRecapScreen extends ConsumerStatefulWidget {
  const VoiceRecapScreen({super.key});

  @override
  ConsumerState<VoiceRecapScreen> createState() => _VoiceRecapScreenState();
}

class _VoiceRecapScreenState extends ConsumerState<VoiceRecapScreen> {
  late final TextEditingController _transcriptController;
  late final ProviderSubscription<RecapDraftState> _recapSubscription;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(recapDraftProvider);
    _transcriptController = TextEditingController(text: initialState.transcript);
    _recapSubscription = ref.listenManual<RecapDraftState>(recapDraftProvider, (prev, next) {
      if (next.transcript != _transcriptController.text) {
        _transcriptController.value = _transcriptController.value.copyWith(
          text: next.transcript,
          selection: TextSelection.collapsed(offset: next.transcript.length),
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
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recap = ref.watch(recapDraftProvider);
    final recapController = ref.read(recapDraftProvider.notifier);
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
                            'Voice Recap',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const ProgressStepper(currentStep: 2),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.amber.withValues(alpha: 0.12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.amber.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mic_none_rounded, color: AppTheme.amber, size: 40),
                          ),
                          const SizedBox(height: 28),
                          const VoiceWaveform(isRecording: true),
                          const SizedBox(height: 28),
                          Text('00:24', style: AppTheme.mono(size: 32, color: AppTheme.amber)),
                          const SizedBox(height: 8),
                          Text(
                              recap.isTranscriptConfirmed ? 'Recap captured and ready to review' : 'Draft your recap naturally',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.softWhite.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: recap.isTranscriptConfirmed ? AppTheme.jade : AppTheme.coral,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              recap.isTranscriptConfirmed ? Icons.check_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECAP PROMPTS TO GUIDE YOU',
                              style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _PromptChip(label: 'Items sold?'),
                                _PromptChip(label: 'Any sold out?'),
                                _PromptChip(label: 'Cash or QR?'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TRANSCRIPT',
                              style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _transcriptController,
                              minLines: 5,
                              maxLines: 7,
                              onChanged: recapController.setTranscript,
                              decoration: const InputDecoration(
                                hintText: 'Example: Sold 12 bihun, 9 mee goreng, cash around RM 180.',
                              ),
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            if (recap.cashSuggestion != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Detected possible cash amount: RM ${recap.cashSuggestion!.toStringAsFixed(2)}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.jade,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        final ok = recapController.confirmTranscript();
                        if (!ok) return;
                        context.go('/cash');
                      },
                      child: const Text('Confirm Recap ->'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: recapController.resetTranscript,
                      child: const Text('Re-record'),
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
              const AppBottomNav(currentRoute: '/voice-recap'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.forestGradientBottom.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}