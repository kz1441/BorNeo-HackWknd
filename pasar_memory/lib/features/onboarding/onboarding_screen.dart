import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final TextEditingController _stallNameController;
  late final ProviderSubscription<OnboardingState> _onboardingSubscription;

  @override
  void initState() {
    super.initState();
    _stallNameController = TextEditingController();

    _onboardingSubscription = ref.listenManual<OnboardingState>(onboardingProvider, (prev, next) {
      final prevError = prev?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != prevError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }

      if (prev?.isSaving == true && next.isSaving == false && next.errorMessage == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Saved.')));
      }
    });
  }

  @override
  void dispose() {
    _onboardingSubscription.close();
    _stallNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE8C8), Color(0xFFF7F0E4)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: Navigator.of(context).canPop()
                        ? () => Navigator.of(context).maybePop()
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('About 1 minute', style: textTheme.labelLarge),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Quick setup',
                style: textTheme.titleMedium?.copyWith(color: colorScheme.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Make the app feel like your own stall from the first screen.',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'This step personalizes the workflow, improves matching, and keeps the rest of the experience lighter.',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionHeader(
                        eyebrow: 'Merchant identity',
                        title: 'Name the stall the way customers know it.',
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _stallNameController,
                        onChanged: controller.setStallName,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Stall name',
                          hintText: 'e.g. Kak Ana Nasi Lemak',
                          prefixIcon: const Icon(Icons.storefront_outlined),
                          errorText: state.didSubmit && state.stallName.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 22),
                      const _SectionHeader(
                        eyebrow: 'Business type',
                        title: 'Pick the closest setup so the UX stays relevant.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: BusinessType.values
                            .map(
                              (businessType) => ChoiceChip(
                                label: Text(businessType.label),
                                selected: state.businessType == businessType,
                                onSelected: (_) => controller.setBusinessType(businessType),
                              ),
                            )
                            .toList(),
                      ),
                      if (state.didSubmit && state.businessType == null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Please choose one option.',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const _SectionHeader(
                        eyebrow: 'Language',
                        title: 'Set the tone for daily use.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppLanguage.values
                            .map(
                              (language) => ChoiceChip(
                                label: Text(language.label),
                                selected: state.language == language,
                                onSelected: (_) => controller.setLanguage(language),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      const _SectionHeader(
                        eyebrow: 'Accepted payments',
                        title: 'Choose every way customers usually pay you.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: PaymentType.values
                            .map(
                              (payment) => FilterChip(
                                label: Text(payment.label),
                                selected: state.acceptedPayments.contains(payment),
                                onSelected: (selected) => controller.togglePayment(payment, selected),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 58,
                        child: FilledButton.icon(
                          onPressed: state.isSaving
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  await controller.submit();
                                },
                          icon: state.isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check_circle_outline_rounded),
                          label: Text(state.isSaving ? 'Saving...' : 'Save and continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                color: const Color(0xFFFFFBF6),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0x140E6B5C),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.tips_and_updates_outlined,
                          color: Color(0xFF0E6B5C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can refine these later. The goal here is fast setup, not perfect setup.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelMedium?.copyWith(
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: textTheme.titleMedium),
      ],
    );
  }
}
