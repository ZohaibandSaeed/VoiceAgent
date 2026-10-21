import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final AgentStatus status;

  const StatusPill({super.key, required this.status});

  String get _label {
    switch (status) {
      case AgentStatus.listening:
        return 'Listening to you...';
      case AgentStatus.thinking:
        return 'Thinking...';
      case AgentStatus.speaking:
        return 'AI Speaking...';
      case AgentStatus.error:
        return 'Issue Encountered';
      case AgentStatus.idle:
        return 'Tap to Speak';
    }
  }

  Color get _color {
    switch (status) {
      case AgentStatus.listening:
        return AppColors.primaryCyan;
      case AgentStatus.thinking:
        return AppColors.accentViolet;
      case AgentStatus.speaking:
        return AppColors.activeGreen;
      case AgentStatus.error:
        return AppColors.errorRed;
      case AgentStatus.idle:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _color.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
