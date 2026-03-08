import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ConfidenceBadgeType {
  confirmed,
  screenshot,
  voice,
  estimated,
  needsReview,
}

class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({
    super.key,
    required this.type,
    this.label,
  });

  final ConfidenceBadgeType type;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(type);

    return Tooltip(
      message: config.tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: config.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 12, color: config.foreground),
            const SizedBox(width: 6),
            Text(
              label ?? config.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: config.foreground,
                    height: 1.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  _BadgeConfig _configFor(ConfidenceBadgeType type) {
    switch (type) {
      case ConfidenceBadgeType.confirmed:
        return const _BadgeConfig(
          label: 'Confirmed by merchant',
          tooltip: 'This field was directly confirmed by the merchant.',
          icon: Icons.check_rounded,
          background: Color(0x1F4CAF7A),
          foreground: AppTheme.jade,
        );
      case ConfidenceBadgeType.screenshot:
        return const _BadgeConfig(
          label: 'From screenshot',
          tooltip: 'This value was extracted from uploaded payment evidence.',
          icon: Icons.photo_camera_outlined,
          background: Color(0x1F71869A),
          foreground: AppTheme.blueGreyBadge,
        );
      case ConfidenceBadgeType.voice:
        return const _BadgeConfig(
          label: 'From voice recap',
          tooltip: 'This value was inferred from the voice recap transcript.',
          icon: Icons.mic_none_rounded,
          background: Color(0x1F8E78D4),
          foreground: AppTheme.voicePurple,
        );
      case ConfidenceBadgeType.estimated:
        return const _BadgeConfig(
          label: 'Estimated',
          tooltip: 'This field is estimated and should be reviewed if needed.',
          icon: Icons.toll_rounded,
          background: Color(0x1FF5A623),
          foreground: AppTheme.amber,
        );
      case ConfidenceBadgeType.needsReview:
        return const _BadgeConfig(
          label: 'Needs Review',
          tooltip: 'This field needs attention before final confirmation.',
          icon: Icons.warning_amber_rounded,
          background: Color(0x1FE8683A),
          foreground: AppTheme.coral,
        );
    }
  }
}

class _BadgeConfig {
  const _BadgeConfig({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final Color background;
  final Color foreground;
}