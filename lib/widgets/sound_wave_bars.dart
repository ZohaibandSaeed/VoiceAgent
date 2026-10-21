import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class SoundWaveBars extends StatefulWidget {
  final AgentStatus status;
  final double soundLevel;

  const SoundWaveBars({
    super.key,
    required this.status,
    required this.soundLevel,
  });

  @override
  State<SoundWaveBars> createState() => _SoundWaveBarsState();
}

class _SoundWaveBarsState extends State<SoundWaveBars> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final int _barCount = 19;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.status == AgentStatus.listening || widget.status == AgentStatus.speaking;

    Color barColor;
    if (widget.status == AgentStatus.listening) {
      barColor = AppColors.primaryCyan;
    } else if (widget.status == AgentStatus.speaking) {
      barColor = AppColors.activeGreen;
    } else if (widget.status == AgentStatus.thinking) {
      barColor = AppColors.accentViolet;
    } else {
      barColor = AppColors.textMuted.withValues(alpha: 0.3);
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_barCount, (index) {
              // Wave height algorithm combining sine wave + soundLevel decibels
              final phase = (index / _barCount) * 2 * math.pi;
              final wave = math.sin((_animController.value * 2 * math.pi) + phase);

              double height;
              if (isActive) {
                // Sound reactive height
                final base = 12.0;
                final dynamicFactor = (wave.abs() * 18) + (widget.soundLevel * 28);
                height = (base + dynamicFactor).clamp(6.0, 46.0);
              } else if (widget.status == AgentStatus.thinking) {
                // Subtle thinking ripple
                height = 8.0 + (wave.abs() * 14.0);
              } else {
                // Resting idle line
                height = 5.0;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 70),
                margin: const EdgeInsets.symmetric(horizontal: 2.2),
                width: 3.5,
                height: height,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: isActive ? 0.9 : 0.4),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
