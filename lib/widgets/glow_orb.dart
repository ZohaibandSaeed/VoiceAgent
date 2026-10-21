import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

/// Ultra-premium Luxury Acoustic Core replacing the old generic circle and mic icon.
/// Crafted with gyroscopic orbital rings, multi-layered liquid glass depth, and
/// a live harmonic acoustic waveform in black, white, and warm light brown / champagne bronze.
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
  late AnimationController _counterRotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _counterRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: false);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant GlowOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      if (widget.status == AgentStatus.thinking) {
        _rotationController.duration = const Duration(seconds: 3);
        _rotationController.repeat();
      } else if (widget.status == AgentStatus.speaking) {
        _rotationController.duration = const Duration(seconds: 6);
        _rotationController.repeat();
      } else {
        _rotationController.duration = const Duration(seconds: 12);
        _rotationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _counterRotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.status == AgentStatus.listening;
    final isSpeaking = widget.status == AgentStatus.speaking;
    final isThinking = widget.status == AgentStatus.thinking;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _counterRotationController,
          _pulseAnimation,
          _waveController,
        ]),
        builder: (context, child) {
          final soundBoost = (isListening || isSpeaking) ? (widget.soundLevel * 0.22) : 0.0;
          final scale = (_pulseAnimation.value + soundBoost).clamp(0.92, 1.35);

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Soft Ambient Halo (Luxury Warm Light Brown & White Glow)
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warmBrown.withValues(alpha: 0.22 + (soundBoost * 0.3)),
                          blurRadius: 55 + (soundBoost * 45),
                          spreadRadius: 10 + (soundBoost * 20),
                        ),
                        BoxShadow(
                          color: AppColors.pureWhite.withValues(alpha: 0.10 + (soundBoost * 0.2)),
                          blurRadius: 35,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // 2. Outer Gyroscopic Orbital Ring with Light Brown Arc Segments
                  Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(224, 224),
                      painter: _OrbitalRingPainter(
                        color: AppColors.lightBrown.withValues(alpha: 0.45),
                        accentColor: AppColors.pureWhite.withValues(alpha: 0.8),
                        strokeWidth: 1.4,
                        dashCount: 8,
                      ),
                    ),
                  ),

                  // 3. Counter-Rotating Inner Gyroscopic Ring
                  Transform.rotate(
                    angle: -_counterRotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(196, 196),
                      painter: _OrbitalRingPainter(
                        color: AppColors.warmBrown.withValues(alpha: 0.35),
                        accentColor: AppColors.lightBrown.withValues(alpha: 0.7),
                        strokeWidth: 1.0,
                        dashCount: 12,
                      ),
                    ),
                  ),

                  // 4. Multi-Layer Liquid Glass Acoustic Sphere
                  Container(
                    width: 164,
                    height: 164,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF282C34), // Inner reflection
                          Color(0xFF16181D), // Obsidian black glass
                          Color(0xFF0D0E11), // Deep black outer edge
                        ],
                        center: Alignment(-0.25, -0.32),
                        radius: 0.85,
                      ),
                      border: Border.all(
                        color: AppColors.lightBrown.withValues(alpha: 0.55),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warmBrown.withValues(alpha: 0.35),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Specular Highlight (Pure White curved glass sheen)
                          Positioned(
                            top: 8,
                            left: 24,
                            right: 24,
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.pureWhite.withValues(alpha: 0.28),
                                    AppColors.pureWhite.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Dynamic Kinetic Harmonic Waves (Live Acoustic Core)
                          CustomPaint(
                            size: const Size(160, 160),
                            painter: _HarmonicWaveCorePainter(
                              progress: _waveController.value,
                              soundLevel: widget.soundLevel,
                              status: widget.status,
                            ),
                          ),

                          // Central Subtle Acoustic Emblem (Minimalist White & Light Brown mark)
                          _buildCenterCoreBadge(widget.status, isThinking),
                        ],
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

  Widget _buildCenterCoreBadge(AgentStatus status, bool isThinking) {
    Color badgeColor = AppColors.pureWhite;
    IconData icon;

    switch (status) {
      case AgentStatus.listening:
        badgeColor = AppColors.pureWhite;
        icon = Icons.graphic_eq_rounded;
      case AgentStatus.thinking:
        badgeColor = AppColors.lightBrown;
        icon = Icons.auto_awesome_rounded;
      case AgentStatus.speaking:
        badgeColor = AppColors.warmBrown;
        icon = Icons.multitrack_audio_rounded;
      case AgentStatus.error:
        badgeColor = AppColors.errorRed;
        icon = Icons.refresh_rounded;
      case AgentStatus.idle:
        badgeColor = AppColors.lightBrown;
        icon = Icons.grain_rounded; // Elegant acoustic particle emblem instead of basic mic
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background.withValues(alpha: 0.65),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: 22,
          color: badgeColor,
        ),
      ),
    );
  }
}

/// Paints delicate gyroscopic orbital rings with dashed luxury light-brown arcs
class _OrbitalRingPainter extends CustomPainter {
  final Color color;
  final Color accentColor;
  final double strokeWidth;
  final int dashCount;

  _OrbitalRingPainter({
    required this.color,
    required this.accentColor,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 0.8;

    final step = (2 * math.pi) / dashCount;
    final arcLength = step * 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * step;
      // Alternate between base and accent arc for luxury timepiece / acoustic look
      final paintToUse = (i % 2 == 0) ? accentPaint : basePaint;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength,
        false,
        paintToUse,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) => false;
}

/// Paints the internal harmonic acoustic waves that undulate in real-time
class _HarmonicWaveCorePainter extends CustomPainter {
  final double progress;
  final double soundLevel;
  final AgentStatus status;

  _HarmonicWaveCorePainter({
    required this.progress,
    required this.soundLevel,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final isListening = status == AgentStatus.listening;
    final isSpeaking = status == AgentStatus.speaking;

    final amplitudeMultiplier = (isListening || isSpeaking)
        ? (18.0 + (soundLevel * 28.0))
        : 8.0;

    // Draw 3 layered harmonic sine waves in white & light brown
    _drawSineWave(
      canvas,
      size,
      amplitude: amplitudeMultiplier * 0.8,
      frequency: 2.2,
      phase: progress * 2 * math.pi,
      color: AppColors.lightBrown.withValues(alpha: 0.6),
      strokeWidth: 2.0,
    );

    _drawSineWave(
      canvas,
      size,
      amplitude: amplitudeMultiplier * 1.1,
      frequency: 3.0,
      phase: (progress * 2 * math.pi) + math.pi / 2,
      color: AppColors.pureWhite.withValues(alpha: 0.75),
      strokeWidth: 2.2,
    );

    _drawSineWave(
      canvas,
      size,
      amplitude: amplitudeMultiplier * 0.6,
      frequency: 1.8,
      phase: (progress * 2 * math.pi) + math.pi,
      color: AppColors.warmBrown.withValues(alpha: 0.5),
      strokeWidth: 1.6,
    );

    // Subtle center glow dot
    final centerDotPaint = Paint()
      ..color = AppColors.pureWhite.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 12, centerDotPaint);
  }

  void _drawSineWave(
    Canvas canvas,
    Size size, {
    required double amplitude,
    required double frequency,
    required double phase,
    required Color color,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final path = Path();
    final midY = size.height / 2;
    const startX = 14.0;
    final endX = size.width - 14.0;

    for (double x = startX; x <= endX; x += 2.0) {
      // Gaussian window to taper wave at circle boundaries
      final normX = (x - startX) / (endX - startX);
      final envelope = math.sin(normX * math.pi);
      final y = midY + math.sin((normX * frequency * 2 * math.pi) + phase) * amplitude * envelope;

      if (x == startX) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HarmonicWaveCorePainter oldDelegate) => true;
}
