import 'package:flutter/material.dart';

class AppStatusBanner extends StatelessWidget {
  final bool offline;
  final String? error;
  final VoidCallback? onDismiss;
  const AppStatusBanner({
    super.key,
    required this.offline,
    this.error,
    this.onDismiss,
  });
  @override
  Widget build(BuildContext c) {
    if (!offline && error == null) return const SizedBox.shrink();
    return Material(
      color: Theme.of(c).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(offline ? Icons.cloud_off_outlined : Icons.error_outline),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error ?? 'Sin conexión. Tus cambios locales se conservarán y podrán sincronizarse cuando vuelva la conexión.',
                ),
              ),
              if (onDismiss != null)
                IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
            ],
          ),
        ),
      ),
    );
  }
}
