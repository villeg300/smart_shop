import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

enum FeedbackDisplayMode { snackbar, popup, silent }

class AppFeedbackService {
  AppFeedbackService._();

  static String formatErrorMessage(
    Object error, {
    String fallbackMessage = 'Une erreur est survenue. Veuillez reessayer.',
  }) {
    var message = error.toString().trim();
    if (message.isEmpty) {
      return fallbackMessage;
    }

    message = message
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^Error:\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (message.isEmpty || message.length > 220) {
      return fallbackMessage;
    }
    return message;
  }

  static void showSuccess({
    required String title,
    required String message,
    FeedbackDisplayMode mode = FeedbackDisplayMode.snackbar,
    String actionLabel = 'OK',
    VoidCallback? onAction,
  }) {
    _show(
      mode: mode,
      title: title,
      message: message,
      isError: false,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError({
    String title = 'Erreur',
    String? message,
    Object? error,
    String fallbackMessage = 'Une erreur est survenue. Veuillez reessayer.',
    FeedbackDisplayMode mode = FeedbackDisplayMode.snackbar,
    String actionLabel = 'Fermer',
    VoidCallback? onAction,
  }) {
    final resolvedMessage =
        message ??
        (error == null
            ? fallbackMessage
            : formatErrorMessage(error, fallbackMessage: fallbackMessage));

    _show(
      mode: mode,
      title: title,
      message: resolvedMessage,
      isError: true,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show({
    required FeedbackDisplayMode mode,
    required String title,
    required String message,
    required bool isError,
    required String actionLabel,
    VoidCallback? onAction,
  }) {
    if (mode == FeedbackDisplayMode.silent) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mode == FeedbackDisplayMode.popup) {
        _showPopup(
          title: title,
          message: message,
          isError: isError,
          actionLabel: actionLabel,
          onAction: onAction,
        );
        return;
      }

      _showSnackbar(title: title, message: message, isError: isError);
    });
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    final context = Get.context;
    final scheme = context == null
        ? ColorScheme.fromSeed(seedColor: Colors.orange)
        : Theme.of(context).colorScheme;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: isError
          ? scheme.errorContainer.withValues(alpha: 0.95)
          : scheme.primaryContainer.withValues(alpha: 0.95),
      colorText: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
        color: isError ? scheme.error : scheme.primary,
      ),
    );
  }

  static void _showPopup({
    required String title,
    required String message,
    required bool isError,
    required String actionLabel,
    VoidCallback? onAction,
  }) {
    final context = Get.context;
    final scheme = context == null
        ? ColorScheme.fromSeed(seedColor: Colors.orange)
        : Theme.of(context).colorScheme;

    final accentColor = isError ? scheme.error : Colors.greenAccent.shade700;
    // final icon = isError ? Icons.error_rounded : Icons.check_circle_rounded;
    final icon = isError
        ? 'assets/animations/error.json'
        : 'assets/animations/order_success.json';

    Get.dialog<void>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container(
              //   width: 64,
              //   height: 64,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: accentColor.withValues(alpha: 0.14),
              //   ),
              //   child: Icon(icon, color: accentColor, size: 34),
              // ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.14),
                ),
                child: Lottie.asset(
                  icon,
                  repeat: false,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (Get.isDialogOpen ?? false) {
                      Get.back<void>();
                    }
                    onAction?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
