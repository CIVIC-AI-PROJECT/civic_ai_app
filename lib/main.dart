import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/core/services/audio_service.dart';
import 'package:civic_ai_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:civic_ai_app/features/voice_chat/viewmodels/voice_chat_viewmodel.dart';
import 'package:civic_ai_app/features/action_center/viewmodels/action_center_viewmodel.dart';
import 'package:civic_ai_app/features/form_filler/viewmodels/form_filler_viewmodel.dart';
import 'package:civic_ai_app/features/escalation_playbook/viewmodels/escalation_playbook_viewmodel.dart';
import 'package:civic_ai_app/features/onboarding/views/onboarding_screen.dart';
import 'package:civic_ai_app/features/voice_chat/views/home_screen.dart';
import 'package:civic_ai_app/features/action_center/views/action_center_screen.dart';
import 'package:civic_ai_app/features/form_filler/views/form_filler_screen.dart';
import 'package:civic_ai_app/features/escalation_playbook/views/escalation_playbook_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AudioService>(create: (_) => AudioService()),

        // ViewModels
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(
          create: (context) =>
              VoiceChatViewModel(audioService: context.read<AudioService>()),
        ),
        ChangeNotifierProvider(create: (_) => ActionCenterViewModel()),
        ChangeNotifierProvider(create: (_) => FormFillerViewModel()),
        ChangeNotifierProvider(create: (_) => EscalationPlaybookViewModel()),
      ],
      child: MaterialApp(
        title: 'CIVIC.AI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const OnboardingScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/action-center': (context) => const ActionCenterScreen(),
          '/form-filler': (context) => const FormFillerScreen(),
          '/escalation-playbook': (context) => const EscalationPlaybookScreen(),
        },
      ),
    );
  }
}
