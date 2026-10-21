import 'package:flutter/material.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/conversation_sheet.dart';
import '../widgets/glow_orb.dart';
import '../widgets/sound_wave_bars.dart';
import '../widgets/status_pill.dart';
import '../widgets/transcript_card.dart';
import '../widgets/voice_settings_sheet.dart';

class VoiceAgentScreen extends StatefulWidget {
  const VoiceAgentScreen({super.key});

  @override
  State<VoiceAgentScreen> createState() => _VoiceAgentScreenState();
}

class _VoiceAgentScreenState extends State<VoiceAgentScreen> {
  final VoiceAgentController _controller = VoiceAgentController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openVoiceSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceSettingsSheet(controller: _controller),
    );
  }

  void _openConversationHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConversationSheet(controller: _controller),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.primaryCyan),
            SizedBox(width: 8),
            Text('Zoid AI', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features & Setup:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(r'100% Free architecture ($0 cost)'),
            _buildFeatureBullet('Native device Speech-To-Text & TTS'),
            _buildFeatureBullet('Groq GPT-OSS-120B ultra-fast inference'),
            _buildFeatureBullet('Urdu, English, Roman Urdu auto-detection'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentViolet.withValues(alpha: 0.3)),
              ),
              child: Text(
                _controller.hasApiKey
                    ? 'API Key Status: Active in .env'
                    : 'API Key missing: Add GROQ_API_KEY inside your .env file',
                style: TextStyle(
                  color: _controller.hasApiKey ? AppColors.activeGreen : AppColors.warningOrange,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryCyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primaryCyan)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final status = _controller.status;

          return Stack(
            children: [
              // Ambient Decorative Glow Blobs in Background
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryCyan.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentViolet.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Main Foreground Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),

                                // Top App Bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceCard,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.primaryCyan.withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.graphic_eq_rounded,
                                              color: AppColors.primaryCyan,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'ZOID',
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2.0,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  'Groq GPT-OSS-120B',
                                                  style: TextStyle(
                                                    color: AppColors.textMuted,
                                                    fontSize: 11,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(6),
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Voice & Accent Settings',
                                          icon: const Icon(
                                            Icons.tune_rounded,
                                            color: AppColors.primaryCyan,
                                            size: 22,
                                          ),
                                          onPressed: _openVoiceSettings,
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(6),
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Info',
                                          icon: const Icon(
                                            Icons.info_outline_rounded,
                                            color: AppColors.textSecondary,
                                            size: 22,
                                          ),
                                          onPressed: _showInfoDialog,
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(6),
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Reset Chat',
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                            color: AppColors.textSecondary,
                                            size: 22,
                                          ),
                                          onPressed: _controller.clearConversation,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Warning Banner if API Key is not set in .env
                                if (!_controller.hasApiKey)
                                  Container(
                                    margin: const EdgeInsets.only(top: 14),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.warningOrange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.warningOrange.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: AppColors.warningOrange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text(
                                            'Add your GROQ_API_KEY in the .env file to enable responses.',
                                            style: TextStyle(
                                              color: AppColors.warningOrange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                const Spacer(flex: 1),

                                // Dynamic Status Pill
                                StatusPill(status: status),

                                const SizedBox(height: 18),

                                // Central Glowing AI Orb
                                GlowOrb(
                                  status: status,
                                  soundLevel: _controller.soundLevel,
                                  onTap: () => _controller.toggleListening(),
                                ),

                                const SizedBox(height: 16),

                                // Sound Wave Frequency Bars
                                SoundWaveBars(
                                  status: status,
                                  soundLevel: _controller.soundLevel,
                                ),

                                const Spacer(flex: 1),

                                // Live Glassmorphic Transcript Card
                                TranscriptCard(
                                  controller: _controller,
                                  onOpenHistory: _openConversationHistory,
                                ),

                                const SizedBox(height: 20),

                                // Bottom Main Action Button
                                _buildBottomActionButton(status),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomActionButton(AgentStatus status) {
    final isListening = status == AgentStatus.listening;
    final isSpeaking = status == AgentStatus.speaking;

    Color buttonColor;
    IconData buttonIcon;
    String buttonLabel;

    if (isListening) {
      buttonColor = AppColors.errorRed;
      buttonIcon = Icons.stop_rounded;
      buttonLabel = 'Tap to Send';
    } else if (isSpeaking) {
      buttonColor = AppColors.warningOrange;
      buttonIcon = Icons.volume_off_rounded;
      buttonLabel = 'Stop AI Voice';
    } else {
      buttonColor = AppColors.primaryCyan;
      buttonIcon = Icons.mic_rounded;
      buttonLabel = 'Tap to Talk';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _controller.toggleListening(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  buttonColor,
                  buttonColor.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.45),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              buttonIcon,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          buttonLabel,
          style: TextStyle(
            color: buttonColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
