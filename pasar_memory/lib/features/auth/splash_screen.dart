import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_theme.dart';
import 'session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _continueFlow);
  }

  void _continueFlow() {
    if (!mounted) return;
    final session = ref.read(sessionProvider);
    if (session.isLoggedIn) {
      context.go(session.menuSetupComplete ? '/' : '/menu-setup');
      return;
    }
    context.go('/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.deepForest,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.7,
            colors: [Color(0x1FF5A623), AppTheme.deepForest],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.menu_book_rounded, size: 96, color: AppTheme.amber),
              const SizedBox(height: 20),
              Text(
                'Pasar Memory',
                style: textTheme.displayLarge?.copyWith(color: AppTheme.softWhite, fontSize: 32),
              ),
              const SizedBox(height: 10),
              Text(
                'Your business. Your memory.',
                style: textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 18),
              const _LoadingDots(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  'Built for ASEAN hawkers 🌿',
                  style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final phase = ((_controller.value * 3) - index).clamp(0.0, 1.0);
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.35 + (0.65 * phase)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}