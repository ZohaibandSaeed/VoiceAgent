import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class TranscriptCard extends StatelessWidget {
  final VoiceAgentController controller;
  final VoidCallback onOpenHistory;

  const TranscriptCard({
    super.key,
    required this.controller,
    required this.onOpenHistory,
  });

  bool _isUrdu(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final status = controller.status;
    final userText = controller.currentTranscript;
    final aiText = controller.currentResponse;

    String header = 'Conversation';
    String displayText = 'Tap the acoustic core or button below to speak in English, Urdu, or Roman Urdu.';
    Color accentColor = AppColors.lightBrown;
    bool isUrduText = false;

    if (status == AgentStatus.listening) {
      header = 'Listening...';
      displayText = userText.isNotEmpty ? userText : 'Listening to your voice...';
      accentColor = AppColors.pureWhite;
      isUrduText = _isUrdu(userText);
    } else if (status == AgentStatus.thinking) {
      header = 'Processing';
      displayText = userText.isNotEmpty ? userText : 'Generating response...';
      accentColor = AppColors.lightBrown;
      isUrduText = _isUrdu(userText);
    } else if (status == AgentStatus.speaking) {
      header = 'Zoid Speaking';
      displayText = aiText.isNotEmpty ? aiText : 'Speaking...';
      accentColor = AppColors.warmBrown;
      isUrduText = _isUrdu(aiText);
    } else if (status == AgentStatus.error && controller.errorMessage != null) {
      header = 'Notice';
      displayText = controller.errorMessage!;
      accentColor = AppColors.errorRed;
    } else if (aiText.isNotEmpty) {
      header = 'Last Response';
      displayText = aiText;
      accentColor = AppColors.lightBrown;
      isUrduText = _isUrdu(aiText);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        header.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  if (controller.messages.isNotEmpty)
                    InkWell(
                      onTap: onOpenHistory,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'History (${controller.messages.length})',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Live Text Display
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  displayText,
                  key: ValueKey<String>(displayText),
                  textAlign: isUrduText ? TextAlign.right : TextAlign.left,
                  textDirection: isUrduText ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.95),
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
