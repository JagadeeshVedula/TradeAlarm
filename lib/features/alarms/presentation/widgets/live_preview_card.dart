import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class LivePreviewCard extends StatelessWidget {
  final String symbol;
  final String? tickerId;
  final double longPct;
  final double shortPct;
  final double price;
  final double longOpenInterestUsd;
  final double shortOpenInterestUsd;
  final double totalOpenInterestUsd;
  final double volumeUsd;
  final DateTime? lastUpdated;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const LivePreviewCard({
    super.key,
    required this.symbol,
    this.tickerId,
    required this.longPct,
    required this.shortPct,
    required this.price,
    this.longOpenInterestUsd = 0.0,
    this.shortOpenInterestUsd = 0.0,
    this.totalOpenInterestUsd = 0.0,
    this.volumeUsd = 0.0,
    this.lastUpdated,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotalOi = totalOpenInterestUsd > 0
        ? totalOpenInterestUsd
        : (longOpenInterestUsd + shortOpenInterestUsd);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Live indicator, Ticker label, Refresh action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentNeonGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE GMX OI DATA · $symbol',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentPurple),
                    )
                  else if (onRefresh != null)
                    InkWell(
                      onTap: onRefresh,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBorderDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.accentNeonGreen),
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (tickerId != null && tickerId!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              tickerId!,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],

          const SizedBox(height: 16),

          // Price & Long/Short OI % Primary Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Price',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatPrice(price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Long vs Short Ratio',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${longPct.round()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentNeonGreen,
                        ),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(fontSize: 18, color: AppTheme.textMuted),
                      ),
                      Text(
                        '${(100 - longPct.round())}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Dual-Color Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (longPct * 10).toInt().clamp(1, 1000),
                    child: Container(color: AppTheme.accentNeonGreen),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (shortPct * 10).toInt().clamp(1, 1000),
                    child: Container(color: AppTheme.accentRed),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorderDark, height: 1),
          const SizedBox(height: 14),

          // Financial Metrics Breakdown Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Total OI',
                  value: Formatters.formatUsd(effectiveTotalOi),
                  valueColor: AppTheme.accentNeonGreen,
                  icon: Icons.pie_chart_outline_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: '24h Volume',
                  value: Formatters.formatUsd(volumeUsd),
                  valueColor: AppTheme.textPrimary,
                  icon: Icons.bar_chart_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Long OI USD',
                  value: Formatters.formatUsd(longOpenInterestUsd),
                  valueColor: AppTheme.accentNeonGreen,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Short OI USD',
                  value: Formatters.formatUsd(shortOpenInterestUsd),
                  valueColor: AppTheme.accentRed,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),

          // Live Fetch Timestamp Footer
          if (lastUpdated != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.history_toggle_off_rounded, size: 12, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Fetched: ${Formatters.formatTime(lastUpdated!)} (${Formatters.formatTimeAgo(lastUpdated)})',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: valueColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
