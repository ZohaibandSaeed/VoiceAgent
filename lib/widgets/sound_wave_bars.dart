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

    Color startColor;
    Color endColor;
    if (widget.status == AgentStatus.listening) {
      startColor = AppColors.pureWhite;
      endColor = AppColors.lightBrown;
    } else if (widget.status == AgentStatus.speaking) {
      startColor = AppColors.lightBrown;
      endColor = AppColors.warmBrown;
    } else if (widget.status == AgentStatus.thinking) {
      startColor = AppColors.warmBrown;
      endColor = AppColors.deepBronze;
    } else {
      startColor = AppColors.lightBrown.withValues(alpha: 0.35);
      endColor = AppColors.warmBrown.withValues(alpha: 0.2);
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_barCount, (index) {
              // Mirrored bell curve factor so center bars are taller
              final centerOffset = (index - (_barCount - 1) / 2.0).abs() / ((_barCount - 1) / 2.0);
              final bellCurve = 1.0 - (centerOffset * 0.45);

              final phase = (index / _barCount) * 2 * math.pi;
              final wave = math.sin((_animController.value * 2 * math.pi) + phase);

              double height;
              if (isActive) {
                final base = 10.0;
                final dynamicFactor = ((wave.abs() * 16) + (widget.soundLevel * 26)) * bellCurve;
                height = (base + dynamicFactor).clamp(6.0, 42.0);
              } else if (widget.status == AgentStatus.thinking) {
                height = (8.0 + (wave.abs() * 14.0)) * bellCurve;
              } else {
                height = 5.0 * bellCurve;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 70),
                margin: const EdgeInsets.symmetric(horizontal: 2.2),
                width: 3.2,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      startColor.withValues(alpha: isActive ? 0.95 : 0.45),
                      endColor.withValues(alpha: isActive ? 0.85 : 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: startColor.withValues(alpha: 0.4),
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
