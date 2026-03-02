import 'package:flutter/material.dart';
import 'package:civic_ai_app/core/theme/app_theme.dart';

class CommonWidgets {
  // Custom elevated button with consistent styling
  static Widget customButton({
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    bool isLoading = false,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.check),
      label: Text(isLoading ? 'Loading...' : label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
      ),
    );
  }

  // Custom card with shadow and border
  static Widget customCard({
    required Widget child,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    Border? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        child: Container(
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
          ),
          padding: padding ?? const EdgeInsets.all(AppTheme.defaultPadding),
          child: child,
        ),
      ),
    );
  }

  // Loading indicator
  static Widget loadingIndicator({Color? color, String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color ?? AppTheme.primaryColor),
          if (message != null) ...[
            const SizedBox(height: AppTheme.defaultPadding),
            Text(message),
          ],
        ],
      ),
    );
  }

  // Error widget
  static Widget errorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Icons.error,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.red),
          const SizedBox(height: AppTheme.defaultPadding),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.defaultPadding),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  // Status badge
  static Widget statusBadge({
    required String status,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final bgColor = backgroundColor ?? Colors.blue;
    final txtColor = textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
      ),
      child: Text(
        status,
        style: TextStyle(color: txtColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Info card with icon
  static Widget infoCard({
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Card(
      color: backgroundColor ?? Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor ?? Colors.blue),
            const SizedBox(width: AppTheme.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppTheme.smallPadding),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Divider with text
  static Widget dividerWithText({required String text, Color? color}) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.smallPadding,
          ),
          child: Text(text, style: TextStyle(color: color ?? Colors.grey)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // Expandable card
  static Widget expandableCard({
    required String title,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: initiallyExpanded,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: content,
        ),
      ],
    );
  }

  // Input field with label
  static Widget labeledTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int? maxLines,
    TextInputType inputType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: AppTheme.smallPadding),
        TextField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
            ),
          ),
        ),
      ],
    );
  }

  // Confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Snackbar helper
  static void showSnackBar({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  // Bottom sheet helper
  static void showCustomBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.largeRadius),
        ),
      ),
      builder: (context) => child,
    );
  }
}
