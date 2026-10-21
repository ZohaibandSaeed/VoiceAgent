import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class GlowOrb extends StatefulWidget {
  final AgentStatus status;
  final double soundLevel;
  final VoidCallback onTap;

  const GlowOrb({
    super.key,
    required this.status,
    required this.soundLevel,
    required this.onTap,
  });

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant GlowOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      if (widget.status == AgentStatus.thinking) {
        _rotationController.duration = const Duration(seconds: 2);
        _rotationController.repeat();
      } else if (widget.status == AgentStatus.speaking) {
        _rotationController.duration = const Duration(seconds: 4);
        _rotationController.repeat();
      } else {
        _rotationController.duration = const Duration(seconds: 8);
        _rotationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Color> _getGlowColors() {
    switch (widget.status) {
      case AgentStatus.listening:
        return [AppColors.primaryCyan, AppColors.glowBlue, AppColors.accentViolet];
      case AgentStatus.thinking:
        return [AppColors.accentViolet, const Color(0xFFEC4899), AppColors.primaryCyan];
      case AgentStatus.speaking:
        return [AppColors.activeGreen, AppColors.primaryCyan, AppColors.glowBlue];
      case AgentStatus.error:
        return [AppColors.errorRed, AppColors.warningOrange, AppColors.surface];
      case AgentStatus.idle:
        return [
          AppColors.primaryCyan.withValues(alpha: 0.8),
          AppColors.accentViolet.withValues(alpha: 0.8),
        ];
    }
  }

  IconData _getCenterIcon() {
    switch (widget.status) {
      case AgentStatus.listening:
        return Icons.mic_rounded;
      case AgentStatus.thinking:
        return Icons.auto_awesome_rounded;
      case AgentStatus.speaking:
        return Icons.graphic_eq_rounded;
      case AgentStatus.error:
        return Icons.refresh_rounded;
      case AgentStatus.idle:
        return Icons.mic_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getGlowColors();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _pulseAnimation]),
        builder: (context, child) {
          // React to voice soundLevel during listening/speaking
          final soundBoost = (widget.status == AgentStatus.listening || widget.status == AgentStatus.speaking)
              ? (widget.soundLevel * 0.28)
              : 0.0;
          final scale = (_pulseAnimation.value + soundBoost).clamp(0.9, 1.4);

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ambient Glow Aura
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.first.withValues(alpha: 0.35),
                          blurRadius: 50 + (soundBoost * 60),
                          spreadRadius: 10 + (soundBoost * 30),
                        ),
                        BoxShadow(
                          color: colors.last.withValues(alpha: 0.25),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                  // Rotating Energy Ring
                  Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            colors.first.withValues(alpha: 0.0),
                            colors.first,
                            colors.last,
                            colors.first.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Inner Glass Sphere Core
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.first.withValues(alpha: 0.9),
                          colors.last.withValues(alpha: 0.8),
                          AppColors.surface.withValues(alpha: 0.95),
                        ],
                        center: const Alignment(-0.25, -0.3),
                        radius: 0.85,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCenterIcon(),
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
