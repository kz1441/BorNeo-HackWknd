import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(label: 'Home', icon: Icons.house_rounded, route: '/'),
      _NavItem(label: 'Tap', icon: Icons.add_circle_outline_rounded, route: '/selling'),
      _NavItem(label: 'Upload', icon: Icons.upload_rounded, route: '/capture'),
      _NavItem(label: 'Recap', icon: Icons.mic_none_rounded, route: '/voice-recap'),
      _NavItem(label: 'Memory', icon: Icons.bookmark_border_rounded, route: '/memory'),
    ];

    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111D16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: items.map((item) {
          final active = item.route == currentRoute;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go(item.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: active
                          ? AppTheme.amber
                          : AppTheme.softWhite.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: active
                                ? AppTheme.amber
                                : AppTheme.softWhite.withValues(alpha: 0.45),
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            height: 1,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppTheme.amber : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.route});

  final String label;
  final IconData icon;
  final String route;
}