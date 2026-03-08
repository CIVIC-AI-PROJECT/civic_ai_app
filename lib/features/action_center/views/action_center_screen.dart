import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/features/action_center/viewmodels/action_center_viewmodel.dart';
import 'package:civic_ai_app/features/voice_chat/viewmodels/voice_chat_viewmodel.dart';
import 'package:civic_ai_app/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/core/widgets/app_bottom_navigation_bar.dart';

class ActionCenterScreen extends StatefulWidget {
  const ActionCenterScreen({super.key});

  @override
  State<ActionCenterScreen> createState() => _ActionCenterScreenState();
}

class _ActionCenterScreenState extends State<ActionCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceChatVM = context.read<VoiceChatViewModel>();
      final actionCenterVM = context.read<ActionCenterViewModel>();
      final onboarding = context.read<OnboardingViewModel>();
      final city =
          (onboarding.selectedDistrict == 'Chandigarh' ||
              onboarding.selectedState == 'Punjab')
          ? 'Chandigarh'
          : 'Delhi';

      if (voiceChatVM.currentGrievance != null) {
        actionCenterVM.setGrievance(voiceChatVM.currentGrievance!);

        if (voiceChatVM.assistResponse != null) {
          actionCenterVM.setAssistResponse(voiceChatVM.assistResponse!);
        } else {
          actionCenterVM.findNearestOffice(
            problem: voiceChatVM.currentGrievance!.description,
            city: city,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text('CIVIC.AI Action Center'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () =>
                Navigator.pushNamed(context, '/intelligence-dashboard'),
          ),
        ],
      ),
      body: Consumer<ActionCenterViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadinessCard(viewModel),
                const SizedBox(height: 22),
                _buildSectionTitle('Recommended Actions'),
                const SizedBox(height: 12),
                _buildRecommendedActions(viewModel),
                const SizedBox(height: 22),
                _buildSectionTitle('Document Checklist'),
                const SizedBox(height: 12),
                _buildDocumentChecklist(viewModel),
                const SizedBox(height: 22),
                _buildSectionTitleWithAction(
                  'Nearest Office',
                  'View Map',
                  onTap: () {
                    if (viewModel.recommendedOffice != null) {
                      viewModel.openMaps();
                    } else {
                      _handleFindNearestOffice(viewModel);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildNearestOfficeCard(viewModel),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildError(viewModel.errorMessage!),
                ],
                const SizedBox(height: 20),
                _buildPrimaryCTA(viewModel),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Finalize your documents and get a printable checklist.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8AA0B3)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildReadinessCard(ActionCenterViewModel viewModel) {
    final readiness = _calculateReadiness(viewModel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F4),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFBFDCDC)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR READINESS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${readiness.toStringAsFixed(0)}% Complete',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: readiness / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFBFDCDC),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions(ActionCenterViewModel viewModel) {
    return Column(
      children: [
        _buildActionCard(
          icon: Icons.how_to_reg_rounded,
          title: 'Complete Form Filing',
          subtitle: 'Use camera extraction and verify your official details.',
          tag: '${math.max(3, viewModel.documentStatus.length)} min task',
          buttonText: 'Start Now',
          onPressed: () => Navigator.pushNamed(context, '/form-filler'),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.account_balance_rounded,
          title: 'Prepare Escalation Path',
          subtitle: 'Review and track escalation steps for unresolved cases.',
          tag: 'Official',
          buttonText: 'Update',
          onPressed: () => Navigator.pushNamed(context, '/escalation-playbook'),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD5DFE7)),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFE3EFF0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppTheme.primaryTeal, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF506480)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F3F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(buttonText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentChecklist(ActionCenterViewModel viewModel) {
    final documents = viewModel.documentStatus.isEmpty
        ? ['Proof of Identity', 'Address Proof']
        : viewModel.documentStatus.take(4).toList();

    return GridView.builder(
      itemCount: documents.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        final title = documents[index];
        final verified = index == 0 && viewModel.documentStatus.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD5DFE7)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                verified ? Icons.fact_check_rounded : Icons.description_outlined,
                color: verified ? AppTheme.primaryTeal : const Color(0xFF94A3B8),
                size: 26,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: verified
                      ? const Color(0xFFDDF3EE)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  verified ? 'VERIFIED' : 'REQUIRED',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: verified
                        ? AppTheme.successGreen
                        : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNearestOfficeCard(ActionCenterViewModel viewModel) {
    if (viewModel.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD5DFE7)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.recommendedOffice == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD5DFE7)),
        ),
        child: Column(
          children: [
            const Icon(Icons.location_off_outlined, size: 36, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No office recommendation yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _handleFindNearestOffice(viewModel),
              icon: const Icon(Icons.my_location),
              label: const Text('Find Nearest Office'),
            ),
          ],
        ),
      );
    }

    final office = viewModel.recommendedOffice!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5DFE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => viewModel.openMaps(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB7E7F7), Color(0xFF8EC5FF)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.map_rounded, size: 52, color: Colors.white),
                  ),
                  const Positioned(
                    left: 16,
                    top: 14,
                    child: Text(
                      'Tap to open navigation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        office.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.near_me, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${office.distanceKm.toStringAsFixed(1)} mi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  office.address,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF556987)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => viewModel.callOffice(),
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Call Office'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => viewModel.openMaps(),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Open Maps'),
                      ),
                    ),
                  ],
                ),
                if (viewModel.alternativeOffices.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                      title: Text(
                        'Alternative Offices',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      children: viewModel.alternativeOffices.take(3).map((alt) {
                        return ListTile(
                          dense: true,
                          title: Text(
                            '${alt.name} (${alt.distanceKm.toStringAsFixed(1)} km)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            alt.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: const Icon(Icons.account_balance_outlined),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCTA(ActionCenterViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () async {
          final pdfPath = await viewModel.generatePDF();
          if (!mounted) return;

          if (pdfPath.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF generated: $pdfPath'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          Navigator.pushNamed(context, '/escalation-playbook');
        },
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Generate PDF / Next Steps'),
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        color: AppTheme.darkText,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSectionTitleWithAction(
    String title,
    String action, {
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  double _calculateReadiness(ActionCenterViewModel viewModel) {
    final hasOffice = viewModel.recommendedOffice != null ? 1.0 : 0.0;
    final hasDocs = viewModel.documentStatus.isNotEmpty ? 1.0 : 0.3;
    final hasChecklist =
        (viewModel.assistResponse?.checklist.steps.isNotEmpty ?? false) ? 1.0 : 0.4;
    final readiness = ((hasOffice + hasDocs + hasChecklist) / 3) * 100;
    return readiness.clamp(20, 95);
  }

  void _handleFindNearestOffice(ActionCenterViewModel viewModel) {
    final onboarding = context.read<OnboardingViewModel>();
    final voiceChatVM = context.read<VoiceChatViewModel>();

    final city =
        (onboarding.selectedDistrict == 'Chandigarh' ||
            onboarding.selectedState == 'Punjab')
        ? 'Chandigarh'
        : 'Delhi';

    final grievanceProblem = viewModel.grievance?.description.trim() ?? '';
    final transcribedProblem = voiceChatVM.transcribedText.trim();

    final problem = grievanceProblem.isNotEmpty
        ? grievanceProblem
        : transcribedProblem.isNotEmpty
        ? transcribedProblem
        : 'Need guidance for civic grievance office';

    viewModel.findNearestOffice(problem: problem, city: city);
  }
}
