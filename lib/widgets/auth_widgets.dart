import 'package:flutter/material.dart';

import '../services/api_service.dart';

const Color kAuthGreen = Color(0xFF0F766E);
const Color kAuthBackground = Color(0xFFF4F7F7);

InputDecoration buildAuthInputDecoration(
  BuildContext context, {
  required String labelText,
  required IconData icon,
  String? hintText,
  Widget? suffixIcon,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: colorScheme.surface.withOpacity(
      Theme.of(context).brightness == Brightness.dark ? 0.72 : 0.95,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.error, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child, this.maxWidth = 920});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? const [Color(0xFF071A17), Color(0xFF0D5948), Color(0xFF143A31)]
        : const [Color(0xFF102A43), Color(0xFF1F8A70), Color(0xFFF4F7F7)];

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withOpacity(0.94)
            : colorScheme.surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class AuthSectionHeader extends StatelessWidget {
  const AuthSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
        ],
      ],
    );
  }
}

class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({super.key, required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isError ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final textColor = isError ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              height: 1.4,
            ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isBusy
              ? SizedBox(
                  key: const ValueKey('busy'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(key: const ValueKey('label'), label),
        ),
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.label,
    required this.progress,
    required this.color,
  });

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Password strength',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: color.withOpacity(0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRequirementTile extends StatelessWidget {
  const PasswordRequirementTile({
    super.key,
    required this.label,
    required this.isSatisfied,
  });

  final String label;
  final bool isSatisfied;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSatisfied ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSatisfied
            ? colorScheme.primaryContainer.withOpacity(0.45)
            : colorScheme.surfaceContainerHighest.withOpacity(0.28),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showApiBaseUrlDialog(
  BuildContext context,
  ApiService apiService,
) async {
  final controller = TextEditingController(text: apiService.baseUrl);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Set API URL'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Backend URL',
            hintText: 'http://192.168.1.10:8000/api',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final baseUrl = controller.text.trim();

              if (baseUrl.isEmpty) {
                return;
              }

              // Close dialog first to avoid framework errors
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              // Then update the URL after widget tree settles
              await Future.delayed(const Duration(milliseconds: 100));
              await apiService.setBaseUrl(baseUrl);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API URL saved. Try login again.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  controller.dispose();
}