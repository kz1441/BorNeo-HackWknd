import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VoiceWaveform extends StatelessWidget {
  const VoiceWaveform({
    super.key,
    this.isRecording = true,
  });

  final bool isRecording;

  static const _heights = [
    10.0, 14.0, 18.0, 24.0, 30.0, 36.0, 28.0, 20.0, 14.0, 10.0, 16.0, 22.0,
    22.0, 16.0, 10.0, 14.0, 20.0, 28.0, 36.0, 30.0, 24.0, 18.0, 14.0, 10.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_heights.length, (index) {
        final color = Color.lerp(AppTheme.amber, AppTheme.jade, index / (_heights.length - 1))!;
        return Container(
          width: 4,
          height: isRecording ? _heights[index] : 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}