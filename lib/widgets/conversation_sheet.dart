import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class ConversationSheet extends StatelessWidget {
  final VoiceAgentController controller;

  const ConversationSheet({super.key, required this.controller});

  bool _isUrdu(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages = controller.messages;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Conversation Log',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (messages.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    controller.clearConversation();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.errorRed),
                  label: const Text(
                    'Clear',
                    style: TextStyle(color: AppColors.errorRed, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Messages list
          if (messages.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No messages yet. Start speaking to begin.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: messages.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUrdu = _isUrdu(msg.text);

                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? AppColors.primaryCyan.withValues(alpha: 0.18)
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                          bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                        ),
                        border: Border.all(
                          color: msg.isUser
                              ? AppColors.primaryCyan.withValues(alpha: 0.4)
                              : AppColors.accentViolet.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.isUser ? 'YOU' : 'AI AGENT',
                            style: TextStyle(
                              color: msg.isUser ? AppColors.primaryCyan : AppColors.accentViolet,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.text,
                            textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
