import 'package:flutter/material.dart';
import '../../../../core/constants/top_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/token_pair.dart';

class TokenPickerModal extends StatefulWidget {
  final TokenOption? currentToken;
  final List<TokenPair>? livePairs;

  const TokenPickerModal({
    super.key,
    this.currentToken,
    this.livePairs,
  });

  static Future<TokenOption?> show(
    BuildContext context, {
    TokenOption? currentToken,
    List<TokenPair>? livePairs,
  }) {
    return showModalBottomSheet<TokenOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TokenPickerModal(
        currentToken: currentToken,
        livePairs: livePairs,
      ),
    );
  }

  @override
  State<TokenPickerModal> createState() => _TokenPickerModalState();
}

class _TokenPickerModalState extends State<TokenPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<TokenOption> _allTokens;
  List<TokenOption> _filteredTokens = [];
  String _selectedCategory = 'All';

  // Category definitions for quick discovery
  static const Map<String, Set<String>> _categories = {
    'Meme': {'DOGE', 'PEPE', 'WIF', 'SHIB', 'BONK', 'FARTCOIN', 'PUMP', 'MOODENG', 'FLOKI', 'ANIME'},
    'DeFi': {'UNI', 'AAVE', 'CRV', 'PENDLE', 'GMX', 'CVX', 'LDO', 'DYDX', 'CAKE', 'MORPHO', 'SYRUP', 'DOLO', 'AERO', 'ENA', 'ZRO'},
    'L1 / L2': {'BTC', 'ETH', 'SOL', 'ARB', 'SUI', 'AVAX', 'NEAR', 'OP', 'APT', 'SEI', 'BNB', 'POL', 'TIA', 'TRX', 'ADA', 'BCH', 'DOT', 'ICP', 'XLM', 'XMR', 'ALGO', 'HBAR', 'CRO', 'LTC', 'KAS', 'ZEC', 'DASH', 'ATOM', 'LINEA', 'BERA', 'MON'},
    'AI': {'TAO', 'RENDER', 'FET', 'AIXBT', 'VIRTUAL', '0G', 'WLD', 'SPCX'},
    'TradFi / Commodities': {'GOLD', 'SILVER', 'WTIOIL', 'BRENTOIL', 'NATGAS', 'SPY', 'QQQ', 'XAUT.v2'},
  };

  @override
  void initState() {
    super.initState();
    _allTokens = TopTokens.getAllTokens(livePairs: widget.livePairs);
    _filteredTokens = _allTokens;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterTokens();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterTokens();
    });
  }

  void _filterTokens() {
    final query = _searchController.text.trim().toLowerCase();
    List<TokenOption> list = _allTokens;

    if (_selectedCategory == 'Top OI') {
      list = list.where((t) => (t.totalOpenInterestUsd ?? 0) > 100000).toList();
    } else if (_categories.containsKey(_selectedCategory)) {
      final validSet = _categories[_selectedCategory]!;
      list = list.where((t) => validSet.contains(t.baseCurrency.toUpperCase())).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((t) {
        return t.symbol.toLowerCase().contains(query) ||
            t.baseCurrency.toLowerCase().contains(query) ||
            t.tickerId.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredTokens = list;
    });
  }

  Color _getBadgeColor(String base) {
    if (_categories['Meme']!.contains(base)) return AppTheme.accentAmber;
    if (_categories['AI']!.contains(base)) return AppTheme.accentPurple;
    if (_categories['TradFi / Commodities']!.contains(base)) return Colors.amber;
    if (base == 'BTC' || base == 'ETH' || base == 'SOL' || base == 'ARB') return AppTheme.accentNeonGreen;
    return AppTheme.accentPurple;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final bool hasExactMatch = _allTokens.any(
      (t) =>
          t.symbol.toLowerCase() == query.toLowerCase() ||
          t.baseCurrency.toLowerCase() == query.toLowerCase(),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.cardBorderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Token / Market',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_allTokens.length} Perp Markets on GMX Arbitrum',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentNeonGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search 100+ tokens (e.g. PEPE, DOGE, SOL, BTC)...',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accentNeonGreen),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.cardDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.cardBorderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.cardBorderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.accentNeonGreen),
                ),
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('Top OI'),
                _buildCategoryChip('Meme'),
                _buildCategoryChip('DeFi'),
                _buildCategoryChip('L1 / L2'),
                _buildCategoryChip('AI'),
                _buildCategoryChip('TradFi / Commodities'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const Divider(height: 1, color: AppTheme.cardBorderDark),

          // Custom Token Option if search query doesn't exactly match
          if (query.isNotEmpty && !hasExactMatch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  final customToken = TopTokens.findBySymbolOrId(query, livePairs: widget.livePairs);
                  Navigator.pop(context, customToken);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentNeonGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Use custom token: "${query.toUpperCase()}-USD"',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
                    ],
                  ),
                ),
              ),
            ),

          // Tokens List
          Expanded(
            child: _filteredTokens.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No token found for "$query"',
                          style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            final custom = TopTokens.findBySymbolOrId(query, livePairs: widget.livePairs);
                            Navigator.pop(context, custom);
                          },
                          child: Text(
                            'Set alarm for "${query.toUpperCase()}-USD" anyway',
                            style: const TextStyle(color: AppTheme.accentNeonGreen),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredTokens.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final token = _filteredTokens[index];
                      final isSelected = widget.currentToken?.symbol.toLowerCase() == token.symbol.toLowerCase();
                      final badgeColor = _getBadgeColor(token.baseCurrency.toUpperCase());

                      return Material(
                        color: isSelected
                            ? AppTheme.accentNeonGreen.withValues(alpha: 0.12)
                            : AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => Navigator.pop(context, token),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.accentNeonGreen.withValues(alpha: 0.6)
                                    : AppTheme.cardBorderDark,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Token Icon Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: badgeColor.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      token.baseCurrency.length > 4
                                          ? token.baseCurrency.substring(0, 4)
                                          : token.baseCurrency,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Token Symbol and market name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            token.symbol,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          if (token.lastPrice != null && token.lastPrice! > 0) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              Formatters.formatPrice(token.lastPrice!),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        token.tickerId,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Live OI metrics
                                if (token.longPct != null && token.totalOpenInterestUsd != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (token.longPct! >= 50.0
                                                  ? AppTheme.accentNeonGreen
                                                  : AppTheme.accentRed)
                                              .withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${token.longPct!.toStringAsFixed(1)}% Long',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: token.longPct! >= 50.0
                                                ? AppTheme.accentNeonGreen
                                                : AppTheme.accentRed,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'OI: ${Formatters.formatUsd(token.totalOpenInterestUsd!)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                if (isSelected) ...[
                                  const SizedBox(width: 10),
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.accentNeonGreen, size: 20),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : AppTheme.textPrimary,
          ),
        ),
        selected: isSelected,
        selectedColor: AppTheme.accentNeonGreen,
        backgroundColor: AppTheme.cardDark,
        side: BorderSide(
          color: isSelected ? AppTheme.accentNeonGreen : AppTheme.cardBorderDark,
        ),
        onSelected: (_) => _onCategorySelected(label),
      ),
    );
  }
}
