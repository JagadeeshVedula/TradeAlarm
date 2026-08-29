import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatusBanner extends StatelessWidget {
  final String statusText;
  final VoidCallback onRefresh;

  const StatusBanner({
    super.key,
    required this.statusText,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = statusText.contains('🟢') || statusText.contains('Connected');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHealthy
            ? AppTheme.accentNeonGreen.withValues(alpha: 0.08)
            : AppTheme.accentRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHealthy
              ? AppTheme.accentNeonGreen.withValues(alpha: 0.3)
              : AppTheme.accentRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: isHealthy ? AppTheme.accentNeonGreen : AppTheme.accentRed,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            color: isHealthy ? AppTheme.accentNeonGreen : AppTheme.accentRed,
            onPressed: onRefresh,
            tooltip: 'Refresh GMX Data',
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
