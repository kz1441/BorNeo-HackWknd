import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

class QuickTapButton extends StatefulWidget {
  const QuickTapButton({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final Widget icon;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<QuickTapButton> createState() => _QuickTapButtonState();
}

class _QuickTapButtonState extends State<QuickTapButton> {
  bool _pressed = false;
  bool _showPlusOne = false;

  Future<void> _handleTap() async {
    setState(() {
      _pressed = false;
      _showPlusOne = true;
    });
    widget.onTap?.call();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showPlusOne = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.count > 0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        scale: _pressed ? 0.94 : 1,
        child: GlassCard(
          radius: 16,
          padding: const EdgeInsets.all(12),
          backgroundColor: active ? AppTheme.jade.withValues(alpha: 0.14) : null,
          borderColor: active ? AppTheme.jade.withValues(alpha: 0.45) : null,
          child: Stack(
            children: [
              if (_showPlusOne)
                Positioned.fill(
                  child: IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, -32 * value),
                          child: Opacity(opacity: 1 - value, child: child),
                        );
                      },
                      child: Center(
                        child: Text(
                          '+1',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.jade,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.amber : Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.count}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: active ? AppTheme.charcoal : AppTheme.softWhite,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: active ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: Center(child: widget.icon),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: active ? AppTheme.softWhite : AppTheme.softWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}