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
}
