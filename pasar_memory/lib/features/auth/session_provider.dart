import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/repository_providers.dart';
import '../../models/merchant.dart';

enum SessionTimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}

enum LoginTarget {
  register,
  menuSetup,
  home,
}

class SessionState {
  const SessionState({
    this.isReady = false,
    this.isBusy = false,
    this.isLoggedIn = false,
    this.displayName = 'Your Name',
    this.businessName = 'Your Stall',
    this.businessType = 'Hawker',
    this.preferredLanguage = 'English',
    this.phoneOrEmail = '',
    this.menuSetupComplete = false,
    this.totalTapCount = 0,
    this.errorMessage,
  });

  final bool isReady;
  final bool isBusy;
  final bool isLoggedIn;
  final String displayName;
  final String businessName;
  final String businessType;
  final String preferredLanguage;
  final String phoneOrEmail;
  final bool menuSetupComplete;
  final int totalTapCount;
  final String? errorMessage;

  String get accountKey => normalizeAccountKey(phoneOrEmail);

  SessionTimeOfDay get timeOfDay {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return SessionTimeOfDay.morning;
    if (hour >= 12 && hour < 18) return SessionTimeOfDay.afternoon;
    if (hour >= 18 && hour < 21) return SessionTimeOfDay.evening;
    return SessionTimeOfDay.night;
  }

  bool get isNight => timeOfDay == SessionTimeOfDay.night;

  SessionState copyWith({
    bool? isReady,
    bool? isBusy,
    bool? isLoggedIn,
    String? displayName,
    String? businessName,
    String? businessType,
    String? preferredLanguage,
    String? phoneOrEmail,
    bool? menuSetupComplete,
    int? totalTapCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      isReady: isReady ?? this.isReady,
      isBusy: isBusy ?? this.isBusy,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      phoneOrEmail: phoneOrEmail ?? this.phoneOrEmail,
      menuSetupComplete: menuSetupComplete ?? this.menuSetupComplete,
      totalTapCount: totalTapCount ?? this.totalTapCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SessionController extends Notifier<SessionState> {
  static const _displayNameKey = 'session.displayName';
  static const _businessNameKey = 'session.businessName';
  static const _businessTypeKey = 'session.businessType';
  static const _preferredLanguageKey = 'session.preferredLanguage';
  static const _phoneOrEmailKey = 'session.phoneOrEmail';
  static const _isLoggedInKey = 'session.isLoggedIn';
  static const _menuSetupCompleteKey = 'session.menuSetupComplete';
  int _mutationCounter = 0;

  String _scopedKey(String baseKey, String accountId) => '$baseKey.$accountId';

  @override
  SessionState build() {
    Future.microtask(_bootstrap);
    return const SessionState();
  }

  String _resolvedDisplayName({
    required SharedPreferences prefs,
    String fallback = 'Your Name',
    String? accountId,
  }) {
    final scopedSavedName = accountId == null || accountId.isEmpty
        ? null
        : prefs.getString(_scopedKey(_displayNameKey, accountId))?.trim();
    if (scopedSavedName != null && scopedSavedName.isNotEmpty) {
      return scopedSavedName;
    }

    final savedName = prefs.getString(_displayNameKey)?.trim();
    if (savedName != null && savedName.isNotEmpty) {
      return savedName;
    }

    return fallback;
  }

  bool _hasStoredAccount(SharedPreferences prefs, String accountId) {
    if (accountId.isEmpty) {
      return false;
    }

    final displayName = prefs.getString(_scopedKey(_displayNameKey, accountId))?.trim();
    final businessName = prefs.getString(_scopedKey(_businessNameKey, accountId))?.trim();
    return (displayName != null && displayName.isNotEmpty) || (businessName != null && businessName.isNotEmpty);
  }

  void _syncMerchantProfile({
    required String accountId,
    required String businessName,
    required String businessType,
  }) {
    if (accountId.isEmpty) {
      return;
    }

    unawaited(() async {
      try {
        final merchantRepo = ref.read(merchantRepositoryProvider);
        final existing = await merchantRepo.getMerchant(accountId: accountId).timeout(const Duration(seconds: 2));
        final merchant = Merchant(
          id: accountId,
          name: businessName,
          businessType: businessType,
          createdAt: existing?.createdAt ?? DateTime.now(),
        );

        if (existing == null) {
          await merchantRepo.createMerchant(merchant).timeout(const Duration(seconds: 2));
        } else {
          await merchantRepo.updateMerchant(merchant).timeout(const Duration(seconds: 2));
        }
      } catch (_) {
        // Auth must not block on best-effort local profile sync.
      }
    }());
  }

  Future<void> _bootstrap() async {
    final mutationAtStart = _mutationCounter;
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhoneOrEmail = prefs.getString(_phoneOrEmailKey) ?? '';
      final accountId = normalizeAccountKey(savedPhoneOrEmail);

      if (mutationAtStart != _mutationCounter) {
        return;
      }

      state = state.copyWith(
        isReady: true,
        isBusy: false,
        isLoggedIn: prefs.getBool(_isLoggedInKey) ?? false,
        displayName: accountId.isEmpty
            ? 'Your Name'
          : _resolvedDisplayName(prefs: prefs, accountId: accountId),
        businessName: accountId.isEmpty
            ? 'Your Stall'
          : (prefs.getString(_scopedKey(_businessNameKey, accountId)) ?? 'Your Stall'),
        businessType: accountId.isEmpty
            ? 'Hawker'
          : (prefs.getString(_scopedKey(_businessTypeKey, accountId)) ?? 'Hawker'),
        preferredLanguage: accountId.isEmpty
            ? 'English'
            : (prefs.getString(_scopedKey(_preferredLanguageKey, accountId)) ?? 'English'),
        phoneOrEmail: savedPhoneOrEmail,
        menuSetupComplete: accountId.isEmpty
            ? false
          : (prefs.getBool(_scopedKey(_menuSetupCompleteKey, accountId)) ?? false),
      );
    } catch (_) {
      if (mutationAtStart != _mutationCounter) {
        return;
      }
      state = state.copyWith(
        isReady: true,
        isBusy: false,
        errorMessage: 'Could not restore your session.',
      );
      return;
    }
  }

  Future<void> register({
    required String displayName,
    required String phoneOrEmail,
    required String businessName,
    required String businessType,
    required String preferredLanguage,
  }) async {
    _mutationCounter++;
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      if (phoneOrEmail.trim().isEmpty) {
        state = state.copyWith(isBusy: false, errorMessage: 'Phone number or email is required.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final accountId = normalizeAccountKey(phoneOrEmail);

      await prefs.setString(_displayNameKey, displayName);
      await prefs.setString(_scopedKey(_displayNameKey, accountId), displayName);
      await prefs.setString(_scopedKey(_businessNameKey, accountId), businessName);
      await prefs.setString(_scopedKey(_businessTypeKey, accountId), businessType);
      await prefs.setString(_scopedKey(_preferredLanguageKey, accountId), preferredLanguage);
      await prefs.setString(_phoneOrEmailKey, phoneOrEmail);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_scopedKey(_menuSetupCompleteKey, accountId), false);

      state = state.copyWith(
        isBusy: false,
        isReady: true,
        isLoggedIn: true,
        displayName: displayName,
        businessName: businessName,
        businessType: businessType,
        preferredLanguage: preferredLanguage,
        phoneOrEmail: phoneOrEmail,
        menuSetupComplete: false,
      );

      _syncMerchantProfile(
        accountId: accountId,
        businessName: businessName,
        businessType: businessType,
      );
      return;
    } catch (_) {
      state = state.copyWith(isBusy: false, errorMessage: 'Could not create account.');
      return;
    }
  }

  Future<LoginTarget> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    _mutationCounter++;
    state = state.copyWith(isBusy: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (phoneOrEmail.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(isBusy: false, errorMessage: 'Enter your login details.');
      return LoginTarget.register;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = normalizeAccountKey(phoneOrEmail.trim());

      if (!_hasStoredAccount(prefs, accountId)) {
        state = state.copyWith(isBusy: false, errorMessage: 'No account found yet. Register first.');
        return LoginTarget.register;
      }

      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_phoneOrEmailKey, phoneOrEmail.trim());

      final menuSetupComplete = prefs.getBool(_scopedKey(_menuSetupCompleteKey, accountId)) ?? false;
      state = state.copyWith(
        isBusy: false,
        isLoggedIn: true,
        isReady: true,
        phoneOrEmail: phoneOrEmail.trim(),
        businessName: prefs.getString(_scopedKey(_businessNameKey, accountId)) ?? state.businessName,
        businessType: prefs.getString(_scopedKey(_businessTypeKey, accountId)) ?? state.businessType,
        displayName: prefs.getString(_scopedKey(_displayNameKey, accountId)) ?? _resolvedDisplayName(
              prefs: prefs,
              accountId: accountId,
              fallback: state.displayName,
            ),
        menuSetupComplete: menuSetupComplete,
      );

      return menuSetupComplete ? LoginTarget.home : LoginTarget.menuSetup;
    } catch (_) {
      state = state.copyWith(isBusy: false, errorMessage: 'Could not log in.');
      return LoginTarget.register;
    }
  }

  Future<void> completeMenuSetup() async {
    _mutationCounter++;
    final prefs = await SharedPreferences.getInstance();
    final accountId = state.accountKey;
    if (accountId.isNotEmpty) {
      await prefs.setBool(_scopedKey(_menuSetupCompleteKey, accountId), true);
    }
    state = state.copyWith(menuSetupComplete: true);
  }

  void setTotalTapCount(int value) {
    state = state.copyWith(totalTapCount: value);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

String normalizeAccountKey(String raw) => raw.trim().toLowerCase();