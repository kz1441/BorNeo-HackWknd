import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper({
    super.key,
    required this.currentStep,
    this.labels = const ['Evidence', 'Recap', 'Cash', 'Confirm'],
    this.completedStepCount,
  });

  final int currentStep;
  final List<String> labels;
  final int? completedStepCount;

  @override
  Widget build(BuildContext context) {
    final completed = completedStepCount ?? (currentStep - 1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          final connectorIndex = index ~/ 2;
          final done = connectorIndex < completed;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: done ? AppTheme.jade : AppTheme.softWhite.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isDone = stepIndex < completed;
        final isActive = stepIndex == currentStep - 1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone
                    ? AppTheme.jade
                    : isActive
                        ? AppTheme.amber
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: isDone || isActive
                    ? null
                    : Border.all(color: AppTheme.softWhite.withValues(alpha: 0.7)),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isActive ? Colors.white : AppTheme.softWhite,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 58,
              child: Text(
                labels[stepIndex],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.softWhite.withValues(alpha: isActive || isDone ? 0.95 : 0.6),
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        );
      }),
    );
  }
}