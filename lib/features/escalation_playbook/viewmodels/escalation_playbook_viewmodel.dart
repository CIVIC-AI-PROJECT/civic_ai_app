import 'package:flutter/material.dart';

class EscalationStep {
  final int stepNumber;
  final String title;
  final String description;
  final String action;
  final String? contactNumber;
  final String? contactLink;
  bool isCompleted;

  EscalationStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.action,
    this.contactNumber,
    this.contactLink,
    this.isCompleted = false,
  });
}

class EscalationPlaybookViewModel extends ChangeNotifier {
  List<EscalationStep> _steps = [];
  int _currentStep = 0;
  bool _isLoading = false;

  List<EscalationStep> get steps => _steps;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;

  EscalationPlaybookViewModel() {
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps = [
      EscalationStep(
        stepNumber: 1,
        title: 'Speak to Local Official',
        description:
            'First, approach the local official (e.g., Ration Dealer, Local Collector) to resolve the issue informally.',
        action:
            'Visit the office with all required documents and clearly explain your grievance.',
        contactNumber: null,
        contactLink: null,
      ),
      EscalationStep(
        stepNumber: 2,
        title: 'File Written Complaint',
        description:
            'If the local official cannot resolve it, file a formal written complaint with the District Officer.',
        action:
            'Submit a formal complaint letter (template provided) to the District Collector\'s office.',
        contactNumber: '+91-XXXX-XXXX-XXXX',
        contactLink: null,
      ),
      EscalationStep(
        stepNumber: 3,
        title: 'Contact CM Helpline',
        description:
            'If still unresolved, escalate to the Chief Minister\'s Helpline for state-level intervention.',
        action:
            'File grievance on official state portal with complaint reference number.',
        contactNumber: '+91-9999-9999-99',
        contactLink: 'https://cmhelpline.gov.in',
      ),
      EscalationStep(
        stepNumber: 4,
        title: 'PGRAM Portal',
        description:
            'Lodge complaint on Pradhan Mantri Gram Sampark Yojana (PGRAM) portal for national-level grievance redressal.',
        action: 'Register on PGRAM portal with all supporting documents.',
        contactNumber: null,
        contactLink: 'https://pgram.nic.in',
      ),
      EscalationStep(
        stepNumber: 5,
        title: 'Seek Legal Remedies',
        description:
            'If administrative remedies fail, consider legal action through courts or administrative tribunals.',
        action:
            'Consult a legal professional to file a PIL or approach the administrative commission.',
        contactNumber: null,
        contactLink: null,
      ),
    ];
  }

  void markStepAsCompleted(int stepNumber) {
    final index = _steps.indexWhere((step) => step.stepNumber == stepNumber);
    if (index != -1) {
      _steps[index].isCompleted = true;
      _currentStep = stepNumber;
      notifyListeners();
    }
  }

  void moveToStep(int stepNumber) {
    if (stepNumber > 0 && stepNumber <= _steps.length) {
      _currentStep = stepNumber;
      notifyListeners();
    }
  }

  EscalationStep? getCurrentStep() {
    if (_currentStep > 0 && _currentStep <= _steps.length) {
      return _steps[_currentStep - 1];
    }
    return null;
  }

  Future<void> callContactNumber(String phoneNumber) async {
    // In production, use url_launcher package
    // await launch('tel:$phoneNumber');
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> openContactLink(String link) async {
    // In production, use url_launcher package
    // await launch(link);
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  double getProgressPercentage() {
    final completedSteps = _steps.where((step) => step.isCompleted).length;
    return (completedSteps / _steps.length) * 100;
  }
}
