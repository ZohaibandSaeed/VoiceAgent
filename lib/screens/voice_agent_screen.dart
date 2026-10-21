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
              // Ambient Decorative Glow Blobs in Background (Warm Light Brown & White luxury lighting)
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warmBrown.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 140,
                right: -70,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBrown.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: -50,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pureWhite.withValues(alpha: 0.03),
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
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(9),
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              width: 36,
                                              height: 36,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surfaceCard,
                                                    borderRadius: BorderRadius.circular(9),
                                                    border: Border.all(
                                                      color: AppColors.lightBrown.withValues(alpha: 0.35),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.graphic_eq_rounded,
                                                    color: AppColors.pureWhite,
                                                    size: 20,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'ZOID',
                                            style: TextStyle(
                                              color: AppColors.pureWhite,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                                            color: AppColors.lightBrown,
                                            size: 22,
                                          ),
                                          onPressed: _openVoiceSettings,
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
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: AppColors.warningOrange,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
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

                                // Central Luxury Acoustic Core
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

                                // Bottom Luxury Action Trigger Button
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

    Color ringColor;
    Color iconColor;
    IconData buttonIcon;
    String buttonLabel;

    if (isListening) {
      ringColor = AppColors.errorRed;
      iconColor = AppColors.pureWhite;
      buttonIcon = Icons.stop_rounded;
      buttonLabel = 'TAP TO SEND';
    } else if (isSpeaking) {
      ringColor = AppColors.warmBrown;
      iconColor = AppColors.pureWhite;
      buttonIcon = Icons.volume_off_rounded;
      buttonLabel = 'STOP AI VOICE';
    } else {
      ringColor = AppColors.lightBrown;
      iconColor = AppColors.pureWhite;
      buttonIcon = Icons.mic_rounded;
      buttonLabel = 'TAP TO SPEAK';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _controller.toggleListening(),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFF282C34),
                  Color(0xFF16181D),
                  Color(0xFF0C0E11),
                ],
                center: Alignment(-0.25, -0.32),
              ),
              border: Border.all(
                color: ringColor.withValues(alpha: 0.65),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: ringColor.withValues(alpha: 0.35),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                buttonIcon,
                color: iconColor,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          buttonLabel,
          style: TextStyle(
            color: ringColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
