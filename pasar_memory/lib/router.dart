import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/cash_entry/cash_entry_screen.dart';
import 'features/evidence/evidence_upload_screen.dart';
import 'features/home/home_screen.dart';
import 'features/ledger/daily_ledger_screen.dart';
import 'features/memory/memory_timeline_screen.dart';
import 'features/menu_setup/menu_setup_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/review/recap_review_screen.dart';
import 'features/selling/selling_screen.dart';
import 'features/voice_recap/voice_recap_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // 1.1.13 Home Screen (Dev 1)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Phase 1 - Dev 2: Onboarding & Evidence Capture
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (context, state) => const MenuSetupScreen(),
      ),
      GoRoute(
        path: '/menu-setup',
        name: 'menu-setup',
        builder: (context, state) => const MenuSetupScreen(isOnboarding: true),
      ),
      GoRoute(
        path: '/capture',
        name: 'capture',
        builder: (context, state) => const EvidenceUploadScreen(),
      ),
      GoRoute(
        path: '/cash',
        name: 'cash',
        builder: (context, state) => const CashEntryScreen(),
      ),
      GoRoute(
        path: '/voice-recap',
        name: 'voice-recap',
        builder: (context, state) => const VoiceRecapScreen(),
      ),
      GoRoute(
        path: '/selling',
        name: 'selling',
        builder: (context, state) => const SellingScreen(),
      ),

      // Phase 1 - Dev 3: OCR & Matching
      GoRoute(
        path: '/matching',
        name: 'matching',
        builder: (context, state) => const RecapReviewScreen(),
      ),

      // Phase 1 - Dev 4: Summary & Review
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) => const RecapReviewScreen(),
      ),
      GoRoute(
        path: '/ledger',
        name: 'ledger',
        builder: (context, state) => const DailyLedgerScreen(),
      ),
      GoRoute(
        path: '/memory',
        name: 'memory',
        builder: (context, state) => const MemoryTimelineScreen(),
      ),

      // Shared/Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const MemoryTimelineScreen(),
      ),
    ],
    // Error handling for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});