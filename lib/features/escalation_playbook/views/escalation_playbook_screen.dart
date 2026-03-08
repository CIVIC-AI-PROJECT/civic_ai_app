import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/features/escalation_playbook/viewmodels/escalation_playbook_viewmodel.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/core/widgets/app_bottom_navigation_bar.dart';

class EscalationPlaybookScreen extends StatefulWidget {
  const EscalationPlaybookScreen({super.key});

  @override
  State<EscalationPlaybookScreen> createState() =>
      _EscalationPlaybookScreenState();
}

class _EscalationPlaybookScreenState extends State<EscalationPlaybookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Escalation Playbook'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Consumer<EscalationPlaybookViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final completedCount = viewModel.steps
              .where((step) => step.isCompleted)
              .length;
          final int activeStepNumber = viewModel.currentStep > 0
              ? viewModel.currentStep
              : (completedCount + 1).clamp(1, viewModel.steps.length);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE CASE #8241',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step $activeStepNumber of ${viewModel.steps.length}',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkText,
                            ),
                      ),
                      Text(
                        '${viewModel.getProgressPercentage().toStringAsFixed(0)}% Complete',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: viewModel.getProgressPercentage() / 100,
                      minHeight: 16,
                      backgroundColor: const Color(0xFFD6E2E5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Stack(
                    children: [
                      Positioned(
                        left: 16,
                        top: 8,
                        bottom: 8,
                        child: Container(
                          width: 2,
                          color: const Color(0xFFCFE0DD),
                        ),
                      ),
                      Column(
                        children: viewModel.steps
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildTimelineStep(
                                context,
                                entry.value,
                                entry.key,
                                viewModel,
                                activeStepNumber,
                                entry.key == viewModel.steps.length - 1,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context,
    EscalationStep step,
    int index,
    EscalationPlaybookViewModel viewModel,
    int activeStepNumber,
    bool isLast,
  ) {
    final isCompleted = step.isCompleted;
    final isActive = step.stepNumber == activeStepNumber;
    final isPending = !isCompleted && !isActive;
    final iconColor = isCompleted || isActive
        ? AppTheme.primaryTeal
        : const Color(0xFF94A3B8);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppTheme.primaryTeal.withValues(alpha: 0.18)
                        : isCompleted
                        ? AppTheme.primaryTeal
                        : const Color(0xFFE2E8F0),
                    border: isActive
                        ? Border.all(color: AppTheme.primaryTeal, width: 2)
                        : null,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isActive
                        ? Icons.more_horiz
                        : index == viewModel.steps.length - 1
                        ? Icons.flag_outlined
                        : Icons.access_time,
                    color: isCompleted || isActive
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: isActive ? 180 : 110,
                    color: isCompleted || isActive
                        ? AppTheme.primaryTeal
                        : const Color(0xFFD9E3E6),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.moveToStep(step.stepNumber),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryTeal : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isPending
                        ? const Color(0xFFDCE5EA)
                        : isCompleted
                        ? const Color(0xFFD0DEE2)
                        : AppTheme.primaryTeal,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _stepIcon(step.stepNumber),
                          color: isActive ? Colors.white : iconColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.darkText,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.92)
                            : const Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isCompleted)
                      Text(
                        'Completed',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (isPending)
                      Text(
                        'Pending completion of current step…',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (isActive) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => viewModel.markStepAsCompleted(
                                step.stepNumber,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryTeal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Mark Complete'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (step.contactNumber != null)
                            _circleAction(
                              icon: Icons.call,
                              onTap: () => viewModel.callContactNumber(
                                step.contactNumber!,
                              ),
                            )
                          else if (step.contactLink != null)
                            _circleAction(
                              icon: Icons.open_in_new,
                              onTap: () =>
                                  viewModel.openContactLink(step.contactLink!),
                            )
                          else
                            _circleAction(
                              icon: Icons.info_outline,
                              onTap: () {},
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: AppTheme.primaryTeal),
      ),
    );
  }

  IconData _stepIcon(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return Icons.warning_amber_rounded;
      case 2:
        return Icons.bar_chart;
      case 3:
        return Icons.gavel;
      case 4:
        return Icons.description_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
}
