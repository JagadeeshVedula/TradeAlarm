import 'package:flutter_test/flutter_test.dart';
import 'package:gmx_oi_alarm/core/constants/top_tokens.dart';
import 'package:gmx_oi_alarm/features/alarms/domain/models/token_pair.dart';

void main() {
  group('TopTokens.findMatchingPair [-USDC] -> [tokenname-USDC] selection logic', () {
    test('Selects [BTC-USDC] over [WBTC.b-USDC] and [WBTC.b-WBTC.b]', () {
      final pairs = [
        TokenPair(
          tickerId: 'BTC/USD [WBTC.b-WBTC.b]',
          baseCurrency: 'BTC',
          targetCurrency: 'USD',
          lastPrice: 77000.0,
          volumeUsd: 1000.0,
          longOpenInterestUsd: 669500.0,
          shortOpenInterestUsd: 330500.0,
        ),
        TokenPair(
          tickerId: 'BTC/USD [WBTC.b-USDC]',
          baseCurrency: 'BTC',
          targetCurrency: 'USD',
          lastPrice: 77000.0,
          volumeUsd: 50000.0,
          longOpenInterestUsd: 435100.0,
          shortOpenInterestUsd: 564900.0,
        ),
        TokenPair(
          tickerId: 'BTC/USD [BTC-USDC]',
          baseCurrency: 'BTC',
          targetCurrency: 'USD',
          lastPrice: 77000.0,
          volumeUsd: 8000000.0,
          longOpenInterestUsd: 13000000.0,
          shortOpenInterestUsd: 12000000.0,
        ),
      ];

      final match = TopTokens.findMatchingPair('BTC-USD', pairs);
      expect(match.tickerId, 'BTC/USD [BTC-USDC]');
    });

    test('Selects [SOL-USDC] over [SOL-SOL] and [WBTC.b-USDC]', () {
      final pairs = [
        TokenPair(
          tickerId: 'SOL/USD [SOL-SOL]',
          baseCurrency: 'SOL',
          targetCurrency: 'USD',
          lastPrice: 95.0,
          volumeUsd: 1000.0,
          longOpenInterestUsd: 60340.0,
          shortOpenInterestUsd: 39660.0,
        ),
        TokenPair(
          tickerId: 'SOL/USD [WBTC.b-USDC]',
          baseCurrency: 'SOL',
          targetCurrency: 'USD',
          lastPrice: 95.0,
          volumeUsd: 5000.0,
          longOpenInterestUsd: 49990.0,
          shortOpenInterestUsd: 50010.0,
        ),
        TokenPair(
          tickerId: 'SOL/USD [SOL-USDC]',
          baseCurrency: 'SOL',
          targetCurrency: 'USD',
          lastPrice: 95.0,
          volumeUsd: 1000000.0,
          longOpenInterestUsd: 1300000.0,
          shortOpenInterestUsd: 1700000.0,
        ),
      ];

      final match = TopTokens.findMatchingPair('SOL-USD', pairs);
      expect(match.tickerId, 'SOL/USD [SOL-USDC]');
    });

    test('Falls back to single [-USDC] pair if [tokenname-USDC] is not present', () {
      final pairs = [
        TokenPair(
          tickerId: 'WBTC/USD [WBTC.b-WBTC.b]',
          baseCurrency: 'WBTC',
          targetCurrency: 'USD',
          lastPrice: 77000.0,
          volumeUsd: 1000.0,
          longOpenInterestUsd: 100.0,
          shortOpenInterestUsd: 100.0,
        ),
        TokenPair(
          tickerId: 'WBTC/USD [WBTC.b-USDC]',
          baseCurrency: 'WBTC',
          targetCurrency: 'USD',
          lastPrice: 77000.0,
          volumeUsd: 50000.0,
          longOpenInterestUsd: 400.0,
          shortOpenInterestUsd: 600.0,
        ),
      ];

      final match = TopTokens.findMatchingPair('WBTC-USD', pairs);
      expect(match.tickerId, 'WBTC/USD [WBTC.b-USDC]');
    });
  });

  group('Full tokens catalog (100+ tokens) and dynamic resolution', () {
    test('TopTokens.list contains over 100 baseline tokens', () {
      expect(TopTokens.list.length, greaterThanOrEqualTo(100));
    });

    test('Finds newly supported tokens by symbol or base currency', () {
      final doge = TopTokens.findBySymbolOrId('DOGE-USD');
      expect(doge.baseCurrency, 'DOGE');
      expect(doge.symbol, 'DOGE-USD');

      final pepe = TopTokens.findBySymbolOrId('PEPE');
      expect(pepe.baseCurrency, 'PEPE');
      expect(pepe.symbol, 'PEPE-USD');

      final trump = TopTokens.findBySymbolOrId('TRUMP-USD');
      expect(trump.baseCurrency, 'TRUMP');

      final gold = TopTokens.findBySymbolOrId('GOLD-USD');
      expect(gold.baseCurrency, 'GOLD');
    });

    test('TokenOption equality works by symbol case-insensitively', () {
      const t1 = TokenOption(tickerId: 'DOGE/USD [ETH-USDC]', symbol: 'DOGE-USD', baseCurrency: 'DOGE', targetCurrency: 'USD');
      const t2 = TokenOption(tickerId: 'DOGE/USD [ETH-USDC]', symbol: 'doge-usd', baseCurrency: 'DOGE', targetCurrency: 'USD');
      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('getAllTokens dynamically includes live pair metrics and new listings', () {
      final livePairs = [
        TokenPair(
          tickerId: 'NEWTOKEN/USD [NEWTOKEN-USDC]',
          baseCurrency: 'NEWTOKEN',
          targetCurrency: 'USD',
          lastPrice: 12.5,
          volumeUsd: 500000.0,
          longOpenInterestUsd: 300000.0,
          shortOpenInterestUsd: 200000.0,
        ),
        TokenPair(
          tickerId: 'DOGE/USD [ETH-USDC]',
          baseCurrency: 'DOGE',
          targetCurrency: 'USD',
          lastPrice: 0.22,
          volumeUsd: 1000000.0,
          longOpenInterestUsd: 800000.0,
          shortOpenInterestUsd: 400000.0,
        ),
      ];

      final all = TopTokens.getAllTokens(livePairs: livePairs);
      expect(all.length, greaterThanOrEqualTo(100));

      final doge = all.firstWhere((t) => t.baseCurrency == 'DOGE');
      expect(doge.totalOpenInterestUsd, 1200000.0);
      expect(doge.longPct, closeTo(66.66, 0.1));

      final newToken = all.firstWhere((t) => t.baseCurrency == 'NEWTOKEN');
      expect(newToken.symbol, 'NEWTOKEN-USD');
      expect(newToken.totalOpenInterestUsd, 500000.0);
    });

    test('findMatchingPair matches any arbitrary newly supported token', () {
      final pairs = [
        TokenPair(
          tickerId: 'PEPE/USD [ETH-USDC]',
          baseCurrency: 'PEPE',
          targetCurrency: 'USD',
          lastPrice: 0.00001,
          volumeUsd: 100000.0,
          longOpenInterestUsd: 10000.0,
          shortOpenInterestUsd: 10000.0,
        ),
        TokenPair(
          tickerId: 'PEPE/USD [PEPE-USDC]',
          baseCurrency: 'PEPE',
          targetCurrency: 'USD',
          lastPrice: 0.00001,
          volumeUsd: 500000.0,
          longOpenInterestUsd: 200000.0,
          shortOpenInterestUsd: 100000.0,
        ),
      ];

      final match = TopTokens.findMatchingPair('PEPE-USD', pairs);
      expect(match.tickerId, 'PEPE/USD [PEPE-USDC]');
      expect(match.longPct, closeTo(66.66, 0.1));
    });
  });
}
