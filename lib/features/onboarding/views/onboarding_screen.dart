import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0; // 0: language, 1: persona, 2: location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.largePadding,
                vertical: AppTheme.defaultPadding,
              ),
              child: Consumer<OnboardingViewModel>(
                builder: (context, viewModel, _) {
                  return Column(
                    children: [
                      const SizedBox(height: 40),
                      // App Logo/Title
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          'CIVIC.AI',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Voice-First Grievance Platform',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildProgressIndicator(),
                      const SizedBox(height: 32),
                      _buildCurrentStep(viewModel),
                      const SizedBox(height: 32),
                      _buildNavigationButtons(viewModel),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentStep == index ? 32 : 12,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: _currentStep >= index
                  ? AppTheme.primaryColor
                  : Colors.grey[300],
              boxShadow: _currentStep >= index
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(OnboardingViewModel viewModel) {
    switch (_currentStep) {
      case 0:
        return _buildLanguageStep(viewModel);
      case 1:
        return _buildPersonaStep(viewModel);
      case 2:
        return _buildLocationStep(viewModel);
      default:
        return const SizedBox();
    }
  }

  Widget _buildLanguageStep(OnboardingViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Your Language',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose your preferred language',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children:
                  [
                        {'en': 'English'},
                        {'hi': 'हिंदी'},
                        {'te': 'తెలుగు'},
                        {'ta': 'தமிழ்'},
                        {'kn': 'ಕನ್ನಡ'},
                        {'mr': 'मराठी'},
                      ]
                      .expand((m) => m.entries)
                      .map(
                        (entry) =>
                            _languageButton(entry.key, entry.value, viewModel),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(
    String code,
    String label,
    OnboardingViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedLanguage == code;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        elevation: isSelected ? 4 : 0,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => viewModel.selectLanguage(code),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    )
                  : null,
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                width: isSelected ? 0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? null : Colors.white,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaStep(OnboardingViewModel viewModel) {
    const personas = ['🌾 Farmer', '👷‍♀️ Worker', '🎓 Student', '👵 Senior'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Who Are You?',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Help us personalize your experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: personas
                  .map(
                    (persona) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: viewModel.selectedPersona == persona ? 4 : 0,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => viewModel.selectPersona(persona),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: viewModel.selectedPersona == persona
                                  ? LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor,
                                        AppTheme.primaryColor.withOpacity(0.8),
                                      ],
                                    )
                                  : null,
                              border: Border.all(
                                color: viewModel.selectedPersona == persona
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300]!,
                                width: viewModel.selectedPersona == persona
                                    ? 0
                                    : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: viewModel.selectedPersona == persona
                                  ? null
                                  : Colors.white,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Text(
                                  persona,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: viewModel.selectedPersona == persona
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                if (viewModel.selectedPersona == persona)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 28,
                                  )
                                else
                                  Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey[400],
                                    size: 28,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(OnboardingViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your state and district',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: viewModel.selectedState,
              items: viewModel.states
                  .map(
                    (state) => DropdownMenuItem(
                      value: state,
                      child: Text(state, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.selectState(value);
                }
              },
              decoration: InputDecoration(
                labelText: 'State',
                hintText: 'Select your state',
                prefixIcon: const Icon(Icons.map),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.selectedState != null)
              DropdownButtonFormField<String>(
                value: viewModel.selectedDistrict,
                items: viewModel
                    .getDistrictsForState(viewModel.selectedState!)
                    .map(
                      (district) => DropdownMenuItem(
                        value: district,
                        child: Text(
                          district,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.selectDistrict(value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'District',
                  hintText: 'Select your district',
                  prefixIcon: const Icon(Icons.location_city),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(OnboardingViewModel viewModel) {
    final canProceed =
        _currentStep == 0 && viewModel.selectedLanguage != null ||
        _currentStep == 1 && viewModel.selectedPersona != null ||
        _currentStep == 2 &&
            viewModel.selectedState != null &&
            viewModel.selectedDistrict != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[400]!, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: !canProceed
                  ? null
                  : _currentStep < 2
                  ? () {
                      setState(() => _currentStep++);
                    }
                  : () async {
                      final result = await viewModel.completeOnboarding(
                        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
                        name: 'User',
                        phoneNumber: '+91-9876543210',
                      );
                      if (mounted && result) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
              icon: Icon(
                _currentStep < 2 ? Icons.arrow_forward : Icons.check_circle,
              ),
              label: Text(
                _currentStep < 2 ? 'Continue' : 'Get Started',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: canProceed ? 4 : 0,
                backgroundColor: canProceed
                    ? AppTheme.primaryColor
                    : Colors.grey[300],
                foregroundColor: canProceed ? Colors.white : Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
