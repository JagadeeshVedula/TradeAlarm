import '../../features/alarms/domain/models/token_pair.dart';

class TokenOption {
  final String tickerId;
  final String symbol;
  final String baseCurrency;
  final String targetCurrency;
  final double? totalOpenInterestUsd;
  final double? longPct;
  final double? shortPct;
  final double? lastPrice;

  const TokenOption({
    required this.tickerId,
    required this.symbol,
    required this.baseCurrency,
    required this.targetCurrency,
    this.totalOpenInterestUsd,
    this.longPct,
    this.shortPct,
    this.lastPrice,
  });

  TokenOption copyWith({
    String? tickerId,
    String? symbol,
    String? baseCurrency,
    String? targetCurrency,
    double? totalOpenInterestUsd,
    double? longPct,
    double? shortPct,
    double? lastPrice,
  }) {
    return TokenOption(
      tickerId: tickerId ?? this.tickerId,
      symbol: symbol ?? this.symbol,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      totalOpenInterestUsd: totalOpenInterestUsd ?? this.totalOpenInterestUsd,
      longPct: longPct ?? this.longPct,
      shortPct: shortPct ?? this.shortPct,
      lastPrice: lastPrice ?? this.lastPrice,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenOption &&
          runtimeType == other.runtimeType &&
          symbol.toLowerCase() == other.symbol.toLowerCase();

  @override
  int get hashCode => symbol.toLowerCase().hashCode;

  @override
  String toString() => symbol;
}

class TopTokens {
  /// Verified tokens list covering all active markets on GMX Arbitrum.
  /// Default options preference is [TOKEN-USDC].
  static const List<TokenOption> list = [
    TokenOption(tickerId: 'BTC/USD [WBTC.b-USDC]', symbol: 'BTC-USD', baseCurrency: 'BTC', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ETH/USD [ETH-USDC]', symbol: 'ETH-USD', baseCurrency: 'ETH', targetCurrency: 'USD'),
    TokenOption(tickerId: 'LINK/USD [LINK-USDC]', symbol: 'LINK-USD', baseCurrency: 'LINK', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SOL/USD [SOL-USDC]', symbol: 'SOL-USD', baseCurrency: 'SOL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'GOLD/USD [ETH-USDC]', symbol: 'GOLD-USD', baseCurrency: 'GOLD', targetCurrency: 'USD'),
    TokenOption(tickerId: 'NATGAS/USD [ETH-USDC]', symbol: 'NATGAS-USD', baseCurrency: 'NATGAS', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ZEC/USD [WBTC.b-USDC]', symbol: 'ZEC-USD', baseCurrency: 'ZEC', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SUI/USD [ETH-USDC]', symbol: 'SUI-USD', baseCurrency: 'SUI', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ONDO/USD [ETH-USDC]', symbol: 'ONDO-USD', baseCurrency: 'ONDO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'GMX/USD [GMX-USDC]', symbol: 'GMX-USD', baseCurrency: 'GMX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'XRP/USD [ETH-USDC]', symbol: 'XRP-USD', baseCurrency: 'XRP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ARB/USD [ARB-USDC]', symbol: 'ARB-USD', baseCurrency: 'ARB', targetCurrency: 'USD'),
    TokenOption(tickerId: 'AVAX/USD [AVAX-USDC]', symbol: 'AVAX-USD', baseCurrency: 'AVAX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SILVER/USD [ETH-USDC]', symbol: 'SILVER-USD', baseCurrency: 'SILVER', targetCurrency: 'USD'),
    TokenOption(tickerId: 'UNI/USD [UNI-USDC]', symbol: 'UNI-USD', baseCurrency: 'UNI', targetCurrency: 'USD'),
    TokenOption(tickerId: 'HYPE/USD [WBTC.b-USDC]', symbol: 'HYPE-USD', baseCurrency: 'HYPE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'DOGE/USD [ETH-USDC]', symbol: 'DOGE-USD', baseCurrency: 'DOGE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'AAVE/USD [AAVE-USDC]', symbol: 'AAVE-USD', baseCurrency: 'AAVE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'QQQ/USD [ETH-USDC]', symbol: 'QQQ-USD', baseCurrency: 'QQQ', targetCurrency: 'USD'),
    TokenOption(tickerId: 'PENGU/USD [WBTC.b-USDC]', symbol: 'PENGU-USD', baseCurrency: 'PENGU', targetCurrency: 'USD'),
    TokenOption(tickerId: 'HBAR/USD [WBTC.b-USDC]', symbol: 'HBAR-USD', baseCurrency: 'HBAR', targetCurrency: 'USD'),
    TokenOption(tickerId: 'CRV/USD [ETH-USDC]', symbol: 'CRV-USD', baseCurrency: 'CRV', targetCurrency: 'USD'),
    TokenOption(tickerId: 'CVX/USD [ETH-USDC]', symbol: 'CVX-USD', baseCurrency: 'CVX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'NEAR/USD [ETH-USDC]', symbol: 'NEAR-USD', baseCurrency: 'NEAR', targetCurrency: 'USD'),
    TokenOption(tickerId: 'PEPE/USD [ETH-USDC]', symbol: 'PEPE-USD', baseCurrency: 'PEPE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'FARTCOIN/USD [WBTC.b-USDC]', symbol: 'FARTCOIN-USD', baseCurrency: 'FARTCOIN', targetCurrency: 'USD'),
    TokenOption(tickerId: 'TAO/USD [WBTC.b-USDC]', symbol: 'TAO-USD', baseCurrency: 'TAO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'VVV/USD [ETH-USDC]', symbol: 'VVV-USD', baseCurrency: 'VVV', targetCurrency: 'USD'),
    TokenOption(tickerId: 'WTIOIL/USD [ETH-USDC]', symbol: 'WTIOIL-USD', baseCurrency: 'WTIOIL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'MON/USD [ETH-USDC]', symbol: 'MON-USD', baseCurrency: 'MON', targetCurrency: 'USD'),
    TokenOption(tickerId: 'XMR/USD [WBTC.b-USDC]', symbol: 'XMR-USD', baseCurrency: 'XMR', targetCurrency: 'USD'),
    TokenOption(tickerId: 'BERA/USD [ETH-USDC]', symbol: 'BERA-USD', baseCurrency: 'BERA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SPCX/USD [ETH-USDC]', symbol: 'SPCX-USD', baseCurrency: 'SPCX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'JUP/USD [WBTC.b-USDC]', symbol: 'JUP-USD', baseCurrency: 'JUP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'LTC/USD [ETH-USDC]', symbol: 'LTC-USD', baseCurrency: 'LTC', targetCurrency: 'USD'),
    TokenOption(tickerId: 'PUMP/USD [WBTC.b-USDC]', symbol: 'PUMP-USD', baseCurrency: 'PUMP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'CRO/USD [WBTC.b-USDC]', symbol: 'CRO-USD', baseCurrency: 'CRO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'BNB/USD [WBTC.b-USDC]', symbol: 'BNB-USD', baseCurrency: 'BNB', targetCurrency: 'USD'),
    TokenOption(tickerId: 'AERO/USD [ETH-USDC]', symbol: 'AERO-USD', baseCurrency: 'AERO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SEI/USD [ETH-USDC]', symbol: 'SEI-USD', baseCurrency: 'SEI', targetCurrency: 'USD'),
    TokenOption(tickerId: 'CC/USD [WBTC.b-USDC]', symbol: 'CC-USD', baseCurrency: 'CC', targetCurrency: 'USD'),
    TokenOption(tickerId: 'XAUT.v2/USD [WBTC.b-USDC]', symbol: 'XAUT.v2-USD', baseCurrency: 'XAUT.v2', targetCurrency: 'USD'),
    TokenOption(tickerId: 'XPL/USD [WBTC.b-USDC]', symbol: 'XPL-USD', baseCurrency: 'XPL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SHIB/USD [ETH-USDC]', symbol: 'SHIB-USD', baseCurrency: 'SHIB', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ICP/USD [WBTC.b-USDC]', symbol: 'ICP-USD', baseCurrency: 'ICP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SPX6900/USD [ETH-USDC]', symbol: 'SPX6900-USD', baseCurrency: 'SPX6900', targetCurrency: 'USD'),
    TokenOption(tickerId: 'FET/USD [ETH-USDC]', symbol: 'FET-USD', baseCurrency: 'FET', targetCurrency: 'USD'),
    TokenOption(tickerId: 'BCH/USD [WBTC.b-USDC]', symbol: 'BCH-USD', baseCurrency: 'BCH', targetCurrency: 'USD'),
    TokenOption(tickerId: 'TIA/USD [ETH-USDC]', symbol: 'TIA-USD', baseCurrency: 'TIA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'TRX/USD [ETH-USDC]', symbol: 'TRX-USD', baseCurrency: 'TRX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'APT/USD [ETH-USDC]', symbol: 'APT-USD', baseCurrency: 'APT', targetCurrency: 'USD'),
    TokenOption(tickerId: 'OP/USD [OP-USDC]', symbol: 'OP-USD', baseCurrency: 'OP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'INJ/USD [WBTC.b-USDC]', symbol: 'INJ-USD', baseCurrency: 'INJ', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SPY/USD [ETH-USDC]', symbol: 'SPY-USD', baseCurrency: 'SPY', targetCurrency: 'USD'),
    TokenOption(tickerId: 'PENDLE/USD [PENDLE-USDC]', symbol: 'PENDLE-USD', baseCurrency: 'PENDLE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'JTO/USD [WBTC.b-USDC]', symbol: 'JTO-USD', baseCurrency: 'JTO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'AVNT/USD [ETH-USDC]', symbol: 'AVNT-USD', baseCurrency: 'AVNT', targetCurrency: 'USD'),
    TokenOption(tickerId: 'BRENTOIL/USD [ETH-USDC]', symbol: 'BRENTOIL-USD', baseCurrency: 'BRENTOIL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'VIRTUAL/USD [WBTC.b-USDC]', symbol: 'VIRTUAL-USD', baseCurrency: 'VIRTUAL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'LDO/USD [ETH-USDC]', symbol: 'LDO-USD', baseCurrency: 'LDO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'KAS/USD [WBTC.b-USDC]', symbol: 'KAS-USD', baseCurrency: 'KAS', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ENA/USD [ETH-USDC]', symbol: 'ENA-USD', baseCurrency: 'ENA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'XLM/USD [WBTC.b-USDC]', symbol: 'XLM-USD', baseCurrency: 'XLM', targetCurrency: 'USD'),
    TokenOption(tickerId: 'LIT/USD [ETH-USDC]', symbol: 'LIT-USD', baseCurrency: 'LIT', targetCurrency: 'USD'),
    TokenOption(tickerId: 'TRUMP/USD [ETH-USDC]', symbol: 'TRUMP-USD', baseCurrency: 'TRUMP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'DOLO/USD [ETH-USDC]', symbol: 'DOLO-USD', baseCurrency: 'DOLO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'MNT/USD [ETH-USDC]', symbol: 'MNT-USD', baseCurrency: 'MNT', targetCurrency: 'USD'),
    TokenOption(tickerId: 'WLD/USD [ETH-USDC]', symbol: 'WLD-USD', baseCurrency: 'WLD', targetCurrency: 'USD'),
    TokenOption(tickerId: 'POL/USD [ETH-USDC]', symbol: 'POL-USD', baseCurrency: 'POL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'BONK/USD [ETH-USDC]', symbol: 'BONK-USD', baseCurrency: 'BONK', targetCurrency: 'USD'),
    TokenOption(tickerId: 'DOT/USD [WBTC.b-USDC]', symbol: 'DOT-USD', baseCurrency: 'DOT', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ZRO/USD [ETH-USDC]', symbol: 'ZRO-USD', baseCurrency: 'ZRO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'RENDER/USD [ETH-USDC]', symbol: 'RENDER-USD', baseCurrency: 'RENDER', targetCurrency: 'USD'),
    TokenOption(tickerId: 'DASH/USD [WBTC.b-USDC]', symbol: 'DASH-USD', baseCurrency: 'DASH', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SYRUP/USD [ETH-USDC]', symbol: 'SYRUP-USD', baseCurrency: 'SYRUP', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ADA/USD [WBTC.b-USDC]', symbol: 'ADA-USD', baseCurrency: 'ADA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'S/USD [WBTC.b-USDC]', symbol: 'S-USD', baseCurrency: 'S', targetCurrency: 'USD'),
    TokenOption(tickerId: 'APE/USD [APE-USDC]', symbol: 'APE-USD', baseCurrency: 'APE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'SKY/USD [ETH-USDC]', symbol: 'SKY-USD', baseCurrency: 'SKY', targetCurrency: 'USD'),
    TokenOption(tickerId: 'STX/USD [WBTC.b-USDC]', symbol: 'STX-USD', baseCurrency: 'STX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'AIXBT/USD [ETH-USDC]', symbol: 'AIXBT-USD', baseCurrency: 'AIXBT', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ORDI/USD [WBTC.b-USDC]', symbol: 'ORDI-USD', baseCurrency: 'ORDI', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ALGO/USD [WBTC.b-USDC]', symbol: 'ALGO-USD', baseCurrency: 'ALGO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'AR/USD [WBTC.b-USDC]', symbol: 'AR-USD', baseCurrency: 'AR', targetCurrency: 'USD'),
    TokenOption(tickerId: 'EIGEN/USD [ETH-USDC]', symbol: 'EIGEN-USD', baseCurrency: 'EIGEN', targetCurrency: 'USD'),
    TokenOption(tickerId: 'CAKE/USD [WBTC.b-USDC]', symbol: 'CAKE-USD', baseCurrency: 'CAKE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'WIF/USD [WBTC.b-USDC]', symbol: 'WIF-USD', baseCurrency: 'WIF', targetCurrency: 'USD'),
    TokenOption(tickerId: 'FIL/USD [WBTC.b-USDC]', symbol: 'FIL-USD', baseCurrency: 'FIL', targetCurrency: 'USD'),
    TokenOption(tickerId: 'FLOKI/USD [WBTC.b-USDC]', symbol: 'FLOKI-USD', baseCurrency: 'FLOKI', targetCurrency: 'USD'),
    TokenOption(tickerId: 'OKB/USD [ETH-USDC]', symbol: 'OKB-USD', baseCurrency: 'OKB', targetCurrency: 'USD'),
    TokenOption(tickerId: 'DYDX/USD [WBTC.b-USDC]', symbol: 'DYDX-USD', baseCurrency: 'DYDX', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ATOM/USD [ETH-USDC]', symbol: 'ATOM-USD', baseCurrency: 'ATOM', targetCurrency: 'USD'),
    TokenOption(tickerId: 'WLFI/USD [ETH-USDC]', symbol: 'WLFI-USD', baseCurrency: 'WLFI', targetCurrency: 'USD'),
    TokenOption(tickerId: 'MOODENG/USD [WBTC.b-USDC]', symbol: 'MOODENG-USD', baseCurrency: 'MOODENG', targetCurrency: 'USD'),
    TokenOption(tickerId: 'MORPHO/USD [ETH-USDC]', symbol: 'MORPHO-USD', baseCurrency: 'MORPHO', targetCurrency: 'USD'),
    TokenOption(tickerId: 'MEGA/USD [ETH-USDC]', symbol: 'MEGA-USD', baseCurrency: 'MEGA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'MET/USD [WBTC.b-USDC]', symbol: 'MET-USD', baseCurrency: 'MET', targetCurrency: 'USD'),
    TokenOption(tickerId: '0G/USD [WBTC.b-USDC]', symbol: '0G-USD', baseCurrency: '0G', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ZORA/USD [ETH-USDC]', symbol: 'ZORA-USD', baseCurrency: 'ZORA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ASTER/USD [WBTC.b-USDC]', symbol: 'ASTER-USD', baseCurrency: 'ASTER', targetCurrency: 'USD'),
    TokenOption(tickerId: 'LINEA/USD [ETH-USDC]', symbol: 'LINEA-USD', baseCurrency: 'LINEA', targetCurrency: 'USD'),
    TokenOption(tickerId: 'CHZ/USD [ETH-USDC]', symbol: 'CHZ-USD', baseCurrency: 'CHZ', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ANIME/USD [ANIME-USDC]', symbol: 'ANIME-USD', baseCurrency: 'ANIME', targetCurrency: 'USD'),
  ];

  /// Returns all available tokens.
  /// If [livePairs] is non-empty, dynamically extracts and prioritizes all active
  /// perp markets from live data enriched with live OI and price, seamlessly
  /// discovering any new tokens listed on GMX.
  static List<TokenOption> getAllTokens({List<TokenPair>? livePairs}) {
    if (livePairs == null || livePairs.isEmpty) {
      return list;
    }

    final Map<String, TokenPair> primaryPairs = {};

    for (final pair in livePairs) {
      if (!pair.isValidPerp) continue;
      final base = pair.baseCurrency.toUpperCase();
      if (!primaryPairs.containsKey(base)) {
        primaryPairs[base] = pair;
      } else {
        final current = primaryPairs[base]!;
        final currentIsUsdc = current.tickerId.toUpperCase().contains('USDC');
        final pairIsUsdc = pair.tickerId.toUpperCase().contains('USDC');

        if (!currentIsUsdc && pairIsUsdc) {
          primaryPairs[base] = pair;
        } else if (currentIsUsdc == pairIsUsdc) {
          if (pair.totalOpenInterestUsd > current.totalOpenInterestUsd) {
            primaryPairs[base] = pair;
          }
        }
      }
    }

    final List<TokenOption> result = [];
    final Set<String> seenSymbols = {};

    for (final pair in primaryPairs.values) {
      final base = pair.baseCurrency.toUpperCase();
      final symbol = '$base-USD';
      seenSymbols.add(symbol.toLowerCase());
      result.add(TokenOption(
        tickerId: pair.tickerId,
        symbol: symbol,
        baseCurrency: base,
        targetCurrency: pair.targetCurrency,
        totalOpenInterestUsd: pair.totalOpenInterestUsd,
        longPct: pair.longPct,
        shortPct: pair.shortPct,
        lastPrice: pair.lastPrice,
      ));
    }

    // Merge static tokens if any were not in livePairs
    for (final staticToken in list) {
      if (!seenSymbols.contains(staticToken.symbol.toLowerCase())) {
        result.add(staticToken);
        seenSymbols.add(staticToken.symbol.toLowerCase());
      }
    }

    // Sort by Total Open Interest descending, fallback alphabetical
    result.sort((a, b) {
      final oiA = a.totalOpenInterestUsd ?? 0.0;
      final oiB = b.totalOpenInterestUsd ?? 0.0;
      if (oiA != oiB) {
        return oiB.compareTo(oiA);
      }
      return a.symbol.compareTo(b.symbol);
    });

    return result;
  }

  /// Finds a TokenOption by symbol, tickerId, or baseCurrency.
  /// If not found in static/live list, safely creates a fallback TokenOption.
  static TokenOption findBySymbolOrId(String identifier, {List<TokenPair>? livePairs}) {
    final clean = identifier.trim();
    final tokens = getAllTokens(livePairs: livePairs);

    for (final t in tokens) {
      if (t.symbol.toLowerCase() == clean.toLowerCase() ||
          t.tickerId.toLowerCase() == clean.toLowerCase() ||
          t.baseCurrency.toLowerCase() == clean.toLowerCase()) {
        return t;
      }
    }

    final base = clean.split('-').first.split('/').first.trim().toUpperCase();
    final sym = clean.contains('-') || clean.contains('/') ? clean.toUpperCase() : '$base-USD';

    return TokenOption(
      tickerId: clean,
      symbol: sym,
      baseCurrency: base,
      targetCurrency: 'USD',
    );
  }

  /// Finds the best-matching TokenPair from live GMX pairs.
  /// Selection Priority (as specified):
  ///   1. Check candidate pairs matching base currency / symbol.
  ///   2. If multiple candidates exist:
  ///      a. First, filter candidates that have '-USDC]' in tickerId (or end with -USDC).
  ///      b. If more than 1 pair has '-USDC]':
  ///         - Prefer the pair matching '[<tokenName>-USDC]' (e.g. '[BTC-USDC]', '[SOL-USDC]').
  ///         - If multiple or none match '[<tokenName>-USDC]', pick the candidate with highest total Open Interest (OI).
  ///      c. If exactly 1 pair has '-USDC]', select it.
  ///      d. If 0 pairs have '-USDC]', pick candidate with highest total Open Interest.
  static TokenPair findMatchingPair(String symbolOrId, List<TokenPair> pairs) {
    if (pairs.isEmpty) {
      throw Exception('Pairs list is empty');
    }

    final token = findBySymbolOrId(symbolOrId, livePairs: pairs);
    final baseSymbol = token.baseCurrency.toUpperCase();

    // 1. Check for exact full tickerId or marketToken match if provided
    for (final p in pairs) {
      if (p.tickerId.toLowerCase() == symbolOrId.toLowerCase() ||
          (p.marketToken != null && p.marketToken!.toLowerCase() == symbolOrId.toLowerCase())) {
        return p;
      }
    }

    // 2. Filter candidates matching base currency (e.g. BTC, SOL, UNI, DOGE, PEPE)
    List<TokenPair> candidates = pairs
        .where((p) => p.baseCurrency.toUpperCase() == baseSymbol)
        .toList();

    // Substring fallback if exact baseCurrency didn't yield matches
    if (candidates.isEmpty) {
      candidates = pairs
          .where((p) => p.tickerId.toUpperCase().contains(baseSymbol))
          .toList();
    }

    if (candidates.isEmpty) {
      return pairs.first;
    }

    if (candidates.length == 1) {
      return candidates.first;
    }

    // Step A: Find candidates that have '-USDC]' or 'USDC' in ticker_id
    final usdcCandidates = candidates.where((p) {
      final tid = p.tickerId.toUpperCase();
      return tid.contains('-USDC]') || tid.contains('USDC');
    }).toList();

    final searchPool = usdcCandidates.isNotEmpty ? usdcCandidates : candidates;

    if (searchPool.length == 1) {
      return searchPool.first;
    }

    // Step B: If more than 1 for this as well, find [tokenname-USDC] as per requirements
    final exactTokenUsdcCandidates = searchPool.where((p) {
      final tid = p.tickerId.toUpperCase();
      return tid.contains('[$baseSymbol-USDC]');
    }).toList();

    if (exactTokenUsdcCandidates.isNotEmpty) {
      if (exactTokenUsdcCandidates.length == 1) {
        return exactTokenUsdcCandidates.first;
      }
      return exactTokenUsdcCandidates.reduce(
        (curr, next) => curr.totalOpenInterestUsd > next.totalOpenInterestUsd ? curr : next,
      );
    }

    // Fallback tie-breaker: Pick candidate with highest total Open Interest
    return searchPool.reduce(
      (curr, next) => curr.totalOpenInterestUsd > next.totalOpenInterestUsd ? curr : next,
    );
  }
}
