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
  late String _selectedLocale;
  late double _pitch;
  late double _speechRate;
  bool _isTesting = false;

  final List<Map<String, String>> _accents = [
    {'code': 'en-US', 'name': 'US American', 'flag': '🇺🇸'},
    {'code': 'en-GB', 'name': 'British English', 'flag': '🇬🇧'},
    {'code': 'en-IN', 'name': 'Indian / Desi', 'flag': '🇮🇳'},
    {'code': 'en-AU', 'name': 'Australian', 'flag': '🇦🇺'},
    {'code': 'en-CA', 'name': 'Canadian', 'flag': '🇨🇦'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.controller.userLocale;
    _pitch = widget.controller.pitch;
    _speechRate = widget.controller.speechRate;
  }

  void _applyChanges() {
    widget.controller.updateVoiceSettings(
      locale: _selectedLocale,
      pitch: _pitch,
      speechRate: _speechRate,
    );
  }

  Future<void> _testVoice() async {
    setState(() => _isTesting = true);
    _applyChanges();
    await widget.controller.testVoiceSettings();
    if (mounted) {
      setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // 1. Accent Selection
            const Text(
              'SELECT ACCENT / REGION',
              style: TextStyle(
                color: AppColors.primaryCyan,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _accents.map((accent) {
                final isSelected = _selectedLocale == accent['code'];
                return ChoiceChip(
                  tooltip: accent['name'],
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
                      setState(() => _selectedLocale = accent['code']!);
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
                  _pitch < 0.9
                      ? 'Deep'
                      : (_pitch > 1.1 ? 'High' : 'Natural (1.0x)'),
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
              min: 0.6,
              max: 1.4,
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
                  _speechRate < 0.45
                      ? 'Slow'
                      : (_speechRate > 0.55 ? 'Fast' : 'Normal (0.5x)'),
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
              min: 0.35,
              max: 0.75,
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
