import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../../models/merchant.dart';

enum BusinessType {
  food,
  drinks,
  groceries,
  services,
  other,
}

enum AppLanguage {
  ms,
  en,
  zh,
  ta,
}

enum PaymentType {
  cash,
  duitNowQr,
  tng,
  grabPay,
  card,
}

extension BusinessTypeLabel on BusinessType {
  String get label {
    switch (this) {
      case BusinessType.food:
        return 'Food';
      case BusinessType.drinks:
        return 'Drinks';
      case BusinessType.groceries:
        return 'Groceries';
      case BusinessType.services:
        return 'Services';
      case BusinessType.other:
        return 'Other';
    }
  }
}

extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.ms:
        return 'BM (Malay)';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.zh:
        return '中文 (Chinese)';
      case AppLanguage.ta:
        return 'தமிழ் (Tamil)';
    }
  }
}

extension PaymentTypeLabel on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.duitNowQr:
        return 'DuitNow QR';
      case PaymentType.tng:
        return 'Touch ’n Go';
      case PaymentType.grabPay:
        return 'GrabPay';
      case PaymentType.card:
        return 'Card';
    }
  }
}

class OnboardingState {
  final String stallName;
  final BusinessType? businessType;
  final AppLanguage language;
  final Set<PaymentType> acceptedPayments;
  final bool isSaving;
  final bool didSubmit;
  final String? errorMessage;

  const OnboardingState({
    this.stallName = '',
    this.businessType,
    this.language = AppLanguage.ms,
    this.acceptedPayments = const <PaymentType>{PaymentType.cash},
    this.isSaving = false,
    this.didSubmit = false,
    this.errorMessage,
  });

  bool get canSubmit =>
      stallName.trim().isNotEmpty && businessType != null && !isSaving;

  OnboardingState copyWith({
    String? stallName,
    BusinessType? businessType,
    AppLanguage? language,
    Set<PaymentType>? acceptedPayments,
    bool? isSaving,
    bool? didSubmit,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      stallName: stallName ?? this.stallName,
      businessType: businessType ?? this.businessType,
      language: language ?? this.language,
      acceptedPayments: acceptedPayments ?? this.acceptedPayments,
      isSaving: isSaving ?? this.isSaving,
      didSubmit: didSubmit ?? this.didSubmit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setStallName(String value) {
    state = state.copyWith(stallName: value, clearError: true);
  }

  void setBusinessType(BusinessType? value) {
    state = state.copyWith(businessType: value, clearError: true);
  }

  void setLanguage(AppLanguage value) {
    state = state.copyWith(language: value, clearError: true);
  }

  void togglePayment(PaymentType paymentType, bool selected) {
    final next = <PaymentType>{...state.acceptedPayments};
    if (selected) {
      next.add(paymentType);
    } else {
      next.remove(paymentType);
    }
    state = state.copyWith(acceptedPayments: next, clearError: true);
  }

  Future<void> submit() async {
    if (!state.canSubmit) {
      state = state.copyWith(
        didSubmit: true,
        errorMessage: 'Please fill in stall name and business type.',
      );
      return;
    }

    state = state.copyWith(isSaving: true, didSubmit: true, clearError: true);

    try {
      final repo = ref.read(merchantRepositoryProvider);
      final existing = await repo.getMerchant();

      final now = DateTime.now();
      final merchant = Merchant(
        id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
        name: state.stallName.trim(),
        businessType: state.businessType!.label,
        createdAt: existing?.createdAt ?? now,
      );

      if (existing == null) {
        await repo.createMerchant(merchant);
      } else {
        await repo.updateMerchant(merchant);
      }

      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not save. Please try again.',
      );
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
