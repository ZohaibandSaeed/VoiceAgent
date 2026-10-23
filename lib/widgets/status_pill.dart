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
        return 'Zoid is thinking...';
      case AgentStatus.speaking:
        return 'AI is speaking...';
      case AgentStatus.error:
        return 'Issue Encountered';
      case AgentStatus.idle:
        return 'Zoid is ready • Tap to speak';
    }
  }

  Color get _color {
    switch (status) {
      case AgentStatus.listening:
        return AppColors.pureWhite;
      case AgentStatus.thinking:
        return AppColors.lightBrown;
      case AgentStatus.speaking:
        return AppColors.warmBrown;
      case AgentStatus.error:
        return AppColors.errorRed;
      case AgentStatus.idle:
        return AppColors.lightBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _color.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.12),
            blurRadius: 14,
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
                  color: _color.withValues(alpha: 0.7),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _color,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
