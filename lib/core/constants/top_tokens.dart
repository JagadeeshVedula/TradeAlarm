import '../../features/alarms/domain/models/token_pair.dart';

class TokenOption {
  final String tickerId;
  final String symbol;
  final String baseCurrency;
  final String targetCurrency;

  const TokenOption({
    required this.tickerId,
    required this.symbol,
    required this.baseCurrency,
    required this.targetCurrency,
  });
}

class TopTokens {
  /// Verified ticker_ids from live GMX Arbitrum API (https://arbitrum.gmxapi.io/v1/pairs)
  /// Default options preference is [TOKEN-USDC].
  static const List<TokenOption> list = [
    TokenOption(tickerId: 'BTC/USD [BTC-USDC]',     symbol: 'BTC-USD',    baseCurrency: 'BTC',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'ETH/USD [WETH-USDC]',    symbol: 'ETH-USD',    baseCurrency: 'ETH',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'SOL/USD [SOL-USDC]',     symbol: 'SOL-USD',    baseCurrency: 'SOL',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'LINK/USD [LINK-USDC]',   symbol: 'LINK-USD',   baseCurrency: 'LINK',   targetCurrency: 'USD'),
    TokenOption(tickerId: 'SUI/USD [SUI-USDC]',     symbol: 'SUI-USD',    baseCurrency: 'SUI',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'AVAX/USD [AVAX-USDC]',   symbol: 'AVAX-USD',   baseCurrency: 'AVAX',   targetCurrency: 'USD'),
    TokenOption(tickerId: 'ARB/USD [ARB-USDC]',     symbol: 'ARB-USD',    baseCurrency: 'ARB',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'GMX/USD [GMX-USDC]',     symbol: 'GMX-USD',    baseCurrency: 'GMX',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'UNI/USD [UNI-USDC]',     symbol: 'UNI-USD',    baseCurrency: 'UNI',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'HYPE/USD [HYPE-USDC]',   symbol: 'HYPE-USD',   baseCurrency: 'HYPE',   targetCurrency: 'USD'),
    TokenOption(tickerId: 'XRP/USD [XRP-USDC]',     symbol: 'XRP-USD',    baseCurrency: 'XRP',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'TAO/USD [TAO-USDC]',     symbol: 'TAO-USD',    baseCurrency: 'TAO',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'DOT/USD [DOT-USDC]',     symbol: 'DOT-USD',    baseCurrency: 'DOT',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'ICP/USD [ICP-USDC]',     symbol: 'ICP-USD',    baseCurrency: 'ICP',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'RENDER/USD [RENDER-USDC]', symbol: 'RENDER-USD', baseCurrency: 'RENDER', targetCurrency: 'USD'),
    TokenOption(tickerId: 'LIT/USD [LIT-USDC]',    symbol: 'LIT-USD',    baseCurrency: 'LIT',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'XPL/USD [XPL-USDC]',     symbol: 'XPL-USD',    baseCurrency: 'XPL',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'VVV/USD [VVV-USDC]',    symbol: 'VVV-USD',    baseCurrency: 'VVV',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'ZEC/USD [ZEC-USDC]',     symbol: 'ZEC-USD',    baseCurrency: 'ZEC',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'SPCX/USD [SPCX-USDC]',   symbol: 'SPCX-USD',   baseCurrency: 'SPCX',   targetCurrency: 'USD'),
    TokenOption(tickerId: 'XMR/USD [XMR-USDC]',     symbol: 'XMR-USD',    baseCurrency: 'XMR',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'PENDLE/USD [PENDLE-USDC]', symbol: 'PENDLE-USD', baseCurrency: 'PENDLE', targetCurrency: 'USD'),
    TokenOption(tickerId: 'ZRO/USD [ZRO-USDC]',    symbol: 'ZRO-USD',    baseCurrency: 'ZRO',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'DYDX/USD [DYDX-USDC]',  symbol: 'DYDX-USD',   baseCurrency: 'DYDX',   targetCurrency: 'USD'),
    TokenOption(tickerId: 'DASH/USD [DASH-USDC]',  symbol: 'DASH-USD',   baseCurrency: 'DASH',   targetCurrency: 'USD'),
    TokenOption(tickerId: 'LDO/USD [LDO-USDC]',    symbol: 'LDO-USD',    baseCurrency: 'LDO',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'SKY/USD [SKY-USDC]',    symbol: 'SKY-USD',    baseCurrency: 'SKY',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'TIA/USD [TIA-USDC]',    symbol: 'TIA-USD',    baseCurrency: 'TIA',    targetCurrency: 'USD'),
    TokenOption(tickerId: 'ASTER/USD [ASTER-USDC]', symbol: 'ASTER-USD',  baseCurrency: 'ASTER',  targetCurrency: 'USD'),
    TokenOption(tickerId: 'BNB/USD [BNB-USDC]',     symbol: 'BNB-USD',    baseCurrency: 'BNB',    targetCurrency: 'USD'),
  ];

  static TokenOption findBySymbolOrId(String identifier) {
    return list.firstWhere(
      (t) =>
          t.symbol.toLowerCase() == identifier.toLowerCase() ||
          t.tickerId.toLowerCase() == identifier.toLowerCase(),
      orElse: () => TokenOption(
        tickerId: identifier,
        symbol: identifier,
        baseCurrency: identifier.split('-').first.split('/').first,
        targetCurrency: 'USD',
      ),
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

    final token = findBySymbolOrId(symbolOrId);
    final baseSymbol = token.baseCurrency.toUpperCase();

    // 1. Check for exact full tickerId or marketToken match if provided
    for (final p in pairs) {
      if (p.tickerId.toLowerCase() == symbolOrId.toLowerCase() ||
          (p.marketToken != null && p.marketToken!.toLowerCase() == symbolOrId.toLowerCase())) {
        return p;
      }
    }

    // 2. Filter candidates matching base currency (e.g. BTC, SOL, UNI)
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
