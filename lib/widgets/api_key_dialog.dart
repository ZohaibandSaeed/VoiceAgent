import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class ApiKeyDialog extends StatefulWidget {
  final VoiceAgentController controller;

  const ApiKeyDialog({super.key, required this.controller});

  static Future<void> show(BuildContext context, VoiceAgentController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApiKeyDialog(controller: controller),
    );
  }

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late TextEditingController _textController;
  bool _obscureText = true;
  bool _isValidating = false;
  String? _validationStatus; // null, 'success', 'error'
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.apiKey);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final key = _textController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _validationStatus = 'error';
        _statusMessage = 'Please enter an API key first.';
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationStatus = null;
      _statusMessage = null;
    });

    final isValid = await widget.controller.validateApiKey(key);

    if (!mounted) return;

    setState(() {
      _isValidating = false;
      if (isValid) {
        _validationStatus = 'success';
        _statusMessage = 'Connected! Groq API key is valid.';
      } else {
        _validationStatus = 'error';
        _statusMessage = 'Invalid API key or network connection failed.';
      }
    });
  }

  Future<void> _saveKey() async {
    final key = _textController.text.trim();
    await widget.controller.saveApiKey(key);

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceCardLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              key.isNotEmpty ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: key.isNotEmpty ? AppColors.activeGreen : AppColors.warningOrange,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              key.isNotEmpty ? 'Groq API Key saved successfully!' : 'Groq API Key cleared.',
              style: const TextStyle(color: AppColors.pureWhite, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && mounted) {
      setState(() {
        _textController.text = data!.text!.trim();
        _validationStatus = null;
        _statusMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasActiveKey = widget.controller.hasApiKey;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(22, 12, 22, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightBrown.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: AppColors.primaryCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Groq API Key',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Configure frontend API access without editing code',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Status Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasActiveKey
                      ? AppColors.activeGreen.withValues(alpha: 0.3)
                      : AppColors.warningOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasActiveKey ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    color: hasActiveKey ? AppColors.activeGreen : AppColors.warningOrange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasActiveKey ? 'Active Key Configured' : 'No API Key Set',
                    style: TextStyle(
                      color: hasActiveKey ? AppColors.activeGreen : AppColors.warningOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    hasActiveKey ? 'Ready for Voice & Chat' : 'Responses Disabled',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Input Field
            TextField(
              controller: _textController,
              obscureText: _obscureText,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceCard,
                hintText: 'gsk_...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightBrown.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightBrown.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5),
                ),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 18),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: _obscureText ? 'Show API Key' : 'Hide API Key',
                      icon: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                    IconButton(
                      tooltip: 'Paste from clipboard',
                      icon: const Icon(Icons.paste_rounded, color: AppColors.primaryCyan, size: 18),
                      onPressed: _pasteFromClipboard,
                    ),
                  ],
                ),
              ),
            ),

            // Validation Status Message
            if (_validationStatus != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    _validationStatus == 'success'
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: _validationStatus == 'success'
                        ? AppColors.activeGreen
                        : AppColors.errorRed,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _statusMessage ?? '',
                      style: TextStyle(
                        color: _validationStatus == 'success'
                            ? AppColors.activeGreen
                            : AppColors.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            // Action Buttons Row
            Row(
              children: [
                // Test Connection Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isValidating ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.lightBrown.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isValidating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryCyan,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_tethering_rounded, size: 16, color: AppColors.lightBrown),
                              SizedBox(width: 6),
                              Text(
                                'Test Key',
                                style: TextStyle(
                                  color: AppColors.lightBrown,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save Key Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Save Key',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Help info
            Center(
              child: Text(
                'Get free instant key from console.groq.com/keys',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
