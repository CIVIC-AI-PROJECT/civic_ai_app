import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/core/services/audio_service.dart';
import 'package:civic_ai_app/core/services/civic_assist_service.dart';
import 'package:civic_ai_app/core/services/grievance_analytics_service.dart';
import 'package:civic_ai_app/core/services/form_processing_service.dart';
import 'package:civic_ai_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:civic_ai_app/features/voice_chat/viewmodels/voice_chat_viewmodel.dart';
import 'package:civic_ai_app/features/action_center/viewmodels/action_center_viewmodel.dart';
import 'package:civic_ai_app/features/form_filler/viewmodels/form_filler_viewmodel.dart';
import 'package:civic_ai_app/features/escalation_playbook/viewmodels/escalation_playbook_viewmodel.dart';
import 'package:civic_ai_app/features/intelligence_dashboard/viewmodels/intelligence_dashboard_viewmodel.dart';
import 'package:civic_ai_app/features/onboarding/views/onboarding_screen.dart';
import 'package:civic_ai_app/features/voice_chat/views/home_screen.dart';
import 'package:civic_ai_app/features/action_center/views/action_center_screen.dart';
import 'package:civic_ai_app/features/form_filler/views/form_filler_screen.dart';
import 'package:civic_ai_app/features/escalation_playbook/views/escalation_playbook_screen.dart';
import 'package:civic_ai_app/features/intelligence_dashboard/views/intelligence_dashboard_screen.dart';

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
        Provider<CivicAssistService>(create: (_) => CivicAssistService()),
        Provider<GrievanceAnalyticsService>(
          create: (_) => GrievanceAnalyticsService(),
        ),
        Provider<FormProcessingService>(create: (_) => FormProcessingService()),

        // ViewModels
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(
          create: (context) => VoiceChatViewModel(
            audioService: context.read<AudioService>(),
            civicAssistService: context.read<CivicAssistService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ActionCenterViewModel(
            civicAssistService: context.read<CivicAssistService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FormFillerViewModel(
            formService: context.read<FormProcessingService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => EscalationPlaybookViewModel()),
        ChangeNotifierProvider(
          create: (context) => IntelligenceDashboardViewModel(
            analyticsService: context.read<GrievanceAnalyticsService>(),
          ),
        ),
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
          '/intelligence-dashboard': (context) =>
              const IntelligenceDashboardScreen(),
        },
      ),
    );
  }
}
