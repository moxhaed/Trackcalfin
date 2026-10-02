import 'package:flutter/material.dart';

/// Lets async work (scan results, background refreshes) show snackbars
/// after the originating screen is gone.
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

void notifyApp(
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final m = appMessengerKey.currentState;
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      // A bar with an action would otherwise stay until dismissed.
      persist: false,
    ),
  );
}
