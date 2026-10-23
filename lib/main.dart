import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/voice_agent_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make system navigation bar and status bar match futuristic dark aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env file is missing or not packaged, continue gracefully
  }

  runApp(const VoiceAgentApp());
}

class VoiceAgentApp extends StatelessWidget {
  const VoiceAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const VoiceAgentScreen(),
    );
  }
}
