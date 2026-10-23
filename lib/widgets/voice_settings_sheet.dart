import 'package:flutter/material.dart';

import '../controllers/voice_agent_controller.dart';
import '../theme/app_theme.dart';

class VoiceSettingsSheet extends StatefulWidget {
  final VoiceAgentController controller;

  const VoiceSettingsSheet({super.key, required this.controller});

  @override
  State<VoiceSettingsSheet> createState() => _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends State<VoiceSettingsSheet> {
  late String _selectedVoiceId;
  late double _pitch;
  late double _speechRate;
  bool _isTesting = false;

  // The 8 Azure Neural accents / voices requested
  final List<Map<String, String>> _accents = [
    {
      'id': 'ur-PK-UzmaNeural',
      'name': 'Uzma',
      'flag': '🇵🇰',
      'country': 'Pakistan (Female)',
      'sample': 'ہیلو! میں زوئڈ ہوں، آپ کا آواز والا اے آئی ساتھی۔',
    },
    {
      'id': 'ur-PK-AsadNeural',
      'name': 'Asad',
      'flag': '🇵🇰',
      'country': 'Pakistan (Male)',
      'sample': 'السلام علیکم! میں زوئڈ ہوں، میں آپ کی کیا مدد کر سکتا ہوں؟',
    },
    {
      'id': 'en-US-JennyNeural',
      'name': 'Jenny',
      'flag': '🇺🇸',
      'country': 'US American',
      'sample': 'Hello! I am Zoid, your personal AI voice companion.',
    },
    {
      'id': 'en-GB-SoniaNeural',
      'name': 'Sonia',
      'flag': '🇬🇧',
      'country': 'British English',
      'sample': 'Good day! How may I be of assistance to you today?',
    },
    {
      'id': 'en-AU-NatashaNeural',
      'name': 'Natasha',
      'flag': '🇦🇺',
      'country': 'Australian',
      'sample': "G'day! Zoid here, ready whenever you need me.",
    },
    {
      'id': 'en-CA-ClaraNeural',
      'name': 'Clara',
      'flag': '🇨🇦',
      'country': 'Canadian',
      'sample': "Hello there! I'm Zoid, glad to assist you today.",
    },
    {
      'id': 'en-IN-NeerjaNeural',
      'name': 'Neerja',
      'flag': '🇮🇳',
      'country': 'Indian / Desi',
      'sample': 'Namaste! How can I help you today?',
    },
    {
      'id': 'en-IE-EmilyNeural',
      'name': 'Emily',
      'flag': '🇮🇪',
      'country': 'Irish English',
      'sample': "Hello! Lovely to meet you, what's on your mind?",
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedVoiceId = widget.controller.selectedVoiceId;
    if (!_accents.any((a) => a['id'] == _selectedVoiceId)) {
      _selectedVoiceId = _accents.first['id']!;
    }
    _pitch = widget.controller.pitch.clamp(0.8, 1.2);
    _speechRate = widget.controller.speechRate.clamp(0.75, 1.25);
  }

  void _applyChanges() {
    widget.controller.updateVoiceSettings(
      voiceId: _selectedVoiceId,
      pitch: _pitch,
      speechRate: _speechRate,
    );
  }

  Future<void> _testVoice() async {
    setState(() => _isTesting = true);
    _applyChanges();

    final currentVoice = _accents.firstWhere(
      (a) => a['id'] == _selectedVoiceId,
      orElse: () => _accents.first,
    );

    try {
      await widget.controller.testVoiceSettings(currentVoice['sample']);
    } catch (_) {}

    if (mounted) {
      setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentVoice = _accents.firstWhere(
      (a) => a['id'] == _selectedVoiceId,
      orElse: () => _accents.first,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: AppColors.primaryCyan,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Voice & Accent Settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Accent Selection Header + Active Voice Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SELECT ACCENT / REGION',
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${currentVoice['flag']} ${currentVoice['name']} • ${currentVoice['country']}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Close-together Flag Chips (Original Classic Style)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _accents.map((accent) {
                final isSelected = _selectedVoiceId == accent['id'];
                return ChoiceChip(
                  tooltip: '${accent['name']} (${accent['country']})',
                  showCheckmark: false,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      accent['flag']!,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryCyan.withValues(alpha: 0.3),
                  backgroundColor: AppColors.surfaceCard,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryCyan
                        : AppColors.accentViolet.withValues(alpha: 0.25),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedVoiceId = accent['id']!);
                      _applyChanges();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // 2. Pitch Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VOICE PITCH (TONE)',
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _pitch < 0.95
                      ? 'Deep'
                      : (_pitch > 1.05 ? 'High' : 'Natural (1.0x)'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Slider(
              value: _pitch,
              min: 0.8,
              max: 1.2,
              divisions: 8,
              activeColor: AppColors.primaryCyan,
              inactiveColor: AppColors.surfaceCard,
              onChanged: (val) {
                setState(() => _pitch = val);
                _applyChanges();
              },
            ),
            const SizedBox(height: 14),

            // 3. Speed Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SPEECH SPEED (RATE)',
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  _speechRate < 0.92
                      ? 'Slow'
                      : (_speechRate > 1.08 ? 'Fast' : 'Normal (1.0x)'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Slider(
              value: _speechRate,
              min: 0.75,
              max: 1.25,
              divisions: 8,
              activeColor: AppColors.accentViolet,
              inactiveColor: AppColors.surfaceCard,
              onChanged: (val) {
                setState(() => _speechRate = val);
                _applyChanges();
              },
            ),
            const SizedBox(height: 24),

            // 4. Test Voice Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testVoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                icon: Icon(
                  _isTesting
                      ? Icons.volume_up_rounded
                      : Icons.play_arrow_rounded,
                  size: 22,
                ),
                label: Text(
                  _isTesting ? 'Playing Sample...' : 'Test Voice',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
