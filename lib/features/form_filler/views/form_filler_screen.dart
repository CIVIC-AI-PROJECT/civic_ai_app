import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:civic_ai_app/features/form_filler/viewmodels/form_filler_viewmodel.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';
import 'package:civic_ai_app/core/widgets/app_bottom_navigation_bar.dart';

class FormFillerScreen extends StatefulWidget {
  const FormFillerScreen({super.key});

  @override
  State<FormFillerScreen> createState() => _FormFillerScreenState();
}

class _FormFillerScreenState extends State<FormFillerScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Upload'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Form Extraction', icon: Icon(Icons.description)),
              Tab(text: 'Image Validation', icon: Icon(Icons.verified)),
            ],
          ),
        ),
        extendBody: true,
        body: Consumer<FormFillerViewModel>(
          builder: (context, viewModel, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: TabBarView(
                children: [
                  _buildExtractionTab(context, viewModel),
                  _buildValidationTab(context, viewModel),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildExtractionTab(
    BuildContext context,
    FormFillerViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppTheme.largePadding,
          right: AppTheme.largePadding,
          top: AppTheme.largePadding,
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.largePadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.info,
                        color: AppTheme.secondaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Capture clear photos and extract form data automatically.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDocumentUploadCard(
              context,
              'Aadhar Card',
              'aadhar',
              viewModel.aadharPath,
              viewModel,
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              context,
              'Ration Card',
              'ratiocard',
              viewModel.ratioCardPath,
              viewModel,
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              context,
              'Other Documents',
              'other',
              viewModel.otherDocPath,
              viewModel,
            ),
            const SizedBox(height: 20),
            if (viewModel.extractedData != null)
              Card(
                elevation: 4,
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.largePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryTeal.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: AppTheme.secondaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Extracted Information',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Type: ${viewModel.extractedData!.formType}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${(viewModel.extractedData!.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color:
                                    viewModel.extractedData!.confidence > 0.75
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Divider(height: 24),
                            const Text(
                              'Extracted Fields:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...viewModel.extractedData!.extractedFields.entries
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.key}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            entry.value.toString(),
                                            style: const TextStyle(height: 1.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            if (viewModel
                                .extractedData!
                                .missingFields
                                .isNotEmpty) ...[
                              const Divider(height: 24),
                              const Text(
                                'Missing Fields:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...viewModel.extractedData!.missingFields.map(
                                (field) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(field),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _buildErrorCard(viewModel),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    viewModel.extractedData != null && !viewModel.isProcessing
                    ? () async {
                        final pdfPath = await viewModel.generateFilledPDF();
                        if (!context.mounted) return;
                        if (pdfPath.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Form generated: $pdfPath'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.file_download, size: 24),
                label: const Text(
                  'Generate Filled Form',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationTab(
    BuildContext context,
    FormFillerViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppTheme.largePadding,
          right: AppTheme.largePadding,
          top: AppTheme.largePadding,
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.largePadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.verified,
                        color: AppTheme.secondaryTeal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Validate document quality first, then switch to Form Extraction to process data.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDocumentUploadCard(
              context,
              'Aadhar Card',
              'aadhar',
              viewModel.aadharPath,
              viewModel,
              validationOnly: true,
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              context,
              'Ration Card',
              'ratiocard',
              viewModel.ratioCardPath,
              viewModel,
              validationOnly: true,
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadCard(
              context,
              'Other Documents',
              'other',
              viewModel.otherDocPath,
              viewModel,
              validationOnly: true,
            ),
            const SizedBox(height: 20),
            if (viewModel.validationResult != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.largePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            viewModel.validationResult!.isValid
                                ? Icons.check_circle
                                : Icons.warning,
                            color: viewModel.validationResult!.isValid
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            viewModel.validationResult!.isBlurry
                                ? 'Image is blurry'
                                : 'Image is not blurry',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Quality Score: ${(viewModel.validationResult!.quality * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: viewModel.validationResult!.quality >= 0.75
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.validationResult!.isBlurry
                            ? 'Please retake the picture with better focus and framing.'
                            : 'The image passed blur detection and is ready to use.',
                        style: TextStyle(
                          color: viewModel.validationResult!.isBlurry
                              ? Colors.orange[800]
                              : Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (viewModel.validationResult!.issues.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Issues:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ...viewModel.validationResult!.issues.map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(issue)),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (viewModel.validationResult!.isBlurry) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final documentType =
                                  viewModel.lastValidatedDocumentType ??
                                  'other';
                              viewModel.captureDocument(
                                documentType: documentType,
                                processAfterValidation: false,
                              );
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Retake Picture'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            _buildErrorCard(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(FormFillerViewModel viewModel) {
    if (viewModel.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        elevation: 2,
        color: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
              IconButton(
                onPressed: () => viewModel.clearError(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard(
    BuildContext context,
    String title,
    String docType,
    String? imagePath,
    FormFillerViewModel viewModel, {
    bool validationOnly = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    docType == 'aadhar'
                        ? Icons.badge
                        : docType == 'ratiocard'
                        ? Icons.description
                        : Icons.insert_drive_file,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (imagePath == null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[100]!, Colors.grey[50]!],
                  ),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 56, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryTeal, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppTheme.secondaryTeal,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => viewModel.captureDocument(
                      documentType: docType,
                      processAfterValidation: !validationOnly,
                    ),
                    icon: const Icon(Icons.camera, size: 22),
                    label: Text(
                      validationOnly ? 'Capture + Validate' : 'Capture',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (imagePath != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => viewModel.validateDocumentQuality(
                        imagePath,
                        documentType: docType,
                      ),
                      icon: const Icon(Icons.check, size: 22),
                      label: const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.secondaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
