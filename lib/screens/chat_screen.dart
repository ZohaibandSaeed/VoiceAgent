import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final VoiceAgentController controller;

  const ChatScreen({super.key, required this.controller});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    widget.controller.addListener(_onControllerUpdate);
    _focusNode.addListener(_onFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animated: false),
    );
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // When keyboard opens on mobile, auto-scroll smoothly to keep latest messages visible (WhatsApp style)
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    widget.controller.removeListener(_onControllerUpdate);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final canSendNow = _textController.text.trim().isNotEmpty;
    if (canSendNow != _canSend) {
      setState(() => _canSend = canSendNow);
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = (presetText ?? _textController.text).trim();
    if (text.isEmpty || widget.controller.status == AgentStatus.thinking) {
      return;
    }

    if (presetText == null) {
      _textController.clear();
      setState(() => _canSend = false);
    }

    _scrollToBottom();
    await widget.controller.sendTextMessage(text);
    _scrollToBottom();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.pureWhite,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Copied to clipboard',
              style: TextStyle(
                color: AppColors.pureWhite,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceCardLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.lightBrown.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  void _confirmClearConversation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.lightBrown.withValues(alpha: 0.25)),
        ),
        title: const Text(
          'Clear Conversation?',
          style: TextStyle(
            color: AppColors.pureWhite,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This will remove all text messages and voice history for this session.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed.withValues(alpha: 0.2),
              foregroundColor: AppColors.errorRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.controller.clearConversation();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.controller.messages;
    final isThinking = widget.controller.status == AgentStatus.thinking;
    final isSpeaking = widget.controller.status == AgentStatus.speaking;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // Message List
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      itemCount: messages.length + (isThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isThinking) {
                          return _buildThinkingIndicator();
                        }
                        return _buildMessageBubble(messages[index], isSpeaking);
                      },
                    ),
            ),

            // Bottom Input Bar
            _buildBottomInputBar(isThinking),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.lightBrown.withValues(alpha: 0.2),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.pureWhite,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.lightBrown.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.pureWhite,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'ZOID CHAT',
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Clear Chat',
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          onPressed: _confirmClearConversation,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.surfaceCardLight.withValues(alpha: 0.4),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: _ZoidOrbAnimation(),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isSpeakingGlobal) {
    final isUser = msg.isUser;
    final isUrdu = RegExp(r'[\u0600-\u06FF]').hasMatch(msg.text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.lightBrown, AppColors.deepBronze],
                ),
                border: Border.all(
                  color: AppColors.pureWhite.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.background,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF22262E) : AppColors.surfaceCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.lightBrown.withValues(alpha: 0.35)
                      : AppColors.surfaceCardLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Header badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUser ? 'YOU' : 'ZOID AI',
                        style: TextStyle(
                          color: isUser
                              ? AppColors.lightBrown
                              : AppColors.primaryCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(msg.timestamp),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Message body
                  SelectableText(
                    msg.text,
                    textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                    textDirection: isUrdu
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Bottom action buttons for AI response
                  if (!isUser) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Listen / TTS button
                        InkWell(
                          onTap: () => widget.controller.speakText(msg.text),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.volume_up_rounded,
                                  size: 15,
                                  color: AppColors.lightBrown.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Listen',
                                  style: TextStyle(
                                    color: AppColors.lightBrown.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Copy text button
                        InkWell(
                          onTap: () => _copyToClipboard(msg.text),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: AppColors.textMuted.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Copy',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
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
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppColors.lightBrown, AppColors.deepBronze],
              ),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: AppColors.background,
              size: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.surfaceCardLight),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.lightBrown,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Zoid is thinking...',
                  style: TextStyle(
                    color: AppColors.lightBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar(bool isThinking) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceCardLight.withValues(alpha: 0.5),
            ),
          ),
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text Input Box
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.lightBrown.withValues(alpha: 0.5)
                      : AppColors.surfaceCardLight,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 14.5,
                  height: 1.35,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask Zoid anything...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send Button
          GestureDetector(
            onTap: _canSend && !isThinking ? () => _handleSend() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _canSend && !isThinking
                    ? const LinearGradient(
                        colors: [AppColors.lightBrown, AppColors.deepBronze],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.surfaceCardLight,
                          AppColors.surfaceCard,
                        ],
                      ),
                boxShadow: _canSend && !isThinking
                    ? [
                        BoxShadow(
                          color: AppColors.lightBrown.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: _canSend && !isThinking
                      ? AppColors.background
                      : AppColors.textMuted,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _ZoidOrbAnimation extends StatefulWidget {
  const _ZoidOrbAnimation();

  @override
  State<_ZoidOrbAnimation> createState() => _ZoidOrbAnimationState();
}

class _ZoidOrbAnimationState extends State<_ZoidOrbAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = _animController.value;
        final pulse = math.sin(progress * 2 * math.pi) * 0.5 + 0.5;

        return Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ambient diffuse glow
                Container(
                  width: 180 + (pulse * 24),
                  height: 180 + (pulse * 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lightBrown.withValues(alpha: 0.12 + (pulse * 0.08)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Outer rotating orbital ring
                Transform.rotate(
                  angle: progress * 2 * math.pi,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.lightBrown.withValues(alpha: 0.18 + (pulse * 0.12)),
                        width: 1.2,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lightBrown.withValues(alpha: 0.85),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightBrown.withValues(alpha: 0.8),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Middle counter-rotating orbital ring
                Transform.rotate(
                  angle: -progress * 2 * math.pi * 0.75,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.warmBrown.withValues(alpha: 0.22 + (pulse * 0.1)),
                        width: 1.0,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.pureWhite.withValues(alpha: 0.9),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.pureWhite,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Inner breathing metallic core
                Container(
                  width: 82 + (pulse * 4),
                  height: 82 + (pulse * 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF262A32),
                        Color(0xFF14171C),
                        Color(0xFF090A0C),
                      ],
                      center: Alignment(-0.25, -0.3),
                    ),
                    border: Border.all(
                      color: AppColors.lightBrown.withValues(alpha: 0.45 + (pulse * 0.3)),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightBrown.withValues(alpha: 0.18 + (pulse * 0.15)),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.graphic_eq_rounded,
                            color: AppColors.lightBrown,
                            size: 34,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
