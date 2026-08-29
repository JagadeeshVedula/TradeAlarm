import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../features/alarms/domain/models/token_pair.dart';

class GmxApiClient {
  final http.Client _client;

  GmxApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all market pairs from GMX Arbitrum API with live OI percentages (from markets/info).
  Future<List<TokenPair>> fetchPairs() async {
    try {
      return await _fetchLiveMarketsInfo();
    } catch (e) {
      // Fallback to legacy v1/pairs API if markets/info is unreachable
      try {
        return await _fetchFromUrl(AppConstants.primaryApiUrl);
      } catch (_) {
        return await _fetchFromUrl(AppConstants.fallbackApiUrl);
      }
    }
  }

  Future<List<TokenPair>> _fetchLiveMarketsInfo() async {
    // Attempt parallel price fetch for enrichment
    Map<String, Map<String, double>> priceMap = {};
    try {
      final legacyPairs = await _fetchFromUrl(AppConstants.primaryApiUrl).timeout(const Duration(seconds: 4));
      for (final p in legacyPairs) {
        priceMap[p.baseCurrency.toUpperCase()] = {
          'price': p.lastPrice,
          'volume': p.volumeUsd,
        };
        priceMap[p.tickerId.toUpperCase()] = {
          'price': p.lastPrice,
          'volume': p.volumeUsd,
        };
      }
    } catch (_) {
      // Price enrichment is optional; fallback silently if delayed
    }

    final response = await _client.get(Uri.parse(AppConstants.marketsInfoApiUrl)).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> marketsList = decoded is Map ? decoded['markets'] ?? [] : decoded;

      final pairs = marketsList.map((item) {
        final map = item as Map<String, dynamic>;
        final name = map['name']?.toString() ?? '';
        String baseCurrency = '';
        if (name.contains('/')) {
          baseCurrency = name.split('/')[0].trim();
        } else if (name.contains('-')) {
          baseCurrency = name.split('-')[0].trim();
        } else {
          baseCurrency = name;
        }

        final pData = priceMap[name.toUpperCase()] ?? priceMap[baseCurrency.toUpperCase()];
        final lastPrice = pData?['price'] ?? 0.0;
        final volumeUsd = pData?['volume'] ?? 0.0;

        return TokenPair.fromMarketInfoJson(
          map,
          lastPrice: lastPrice,
          volumeUsd: volumeUsd,
        );
      }).where((pair) => pair.isValidPerp).toList();

      return pairs;
    } else {
      throw Exception('Failed to load GMX markets info. Status: ${response.statusCode}');
    }
  }

  Future<List<TokenPair>> _fetchFromUrl(String url) async {
    final response = await _client.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
        );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final pairs = jsonList
          .map((item) => TokenPair.fromJson(item as Map<String, dynamic>))
          .where((pair) => pair.isValidPerp)
          .toList();
      return pairs;
    } else {
      throw Exception('Failed to load GMX pairs. Status: ${response.statusCode}');
    }
  }

  /// Helper to fetch a single token pair by tickerId or symbol for live preview.
  Future<TokenPair?> fetchTokenPair(String identifier) async {
    final pairs = await fetchPairs();
    return pairs.firstWhere(
      (p) => p.tickerId == identifier || p.baseCurrency == identifier || '${p.baseCurrency}-${p.targetCurrency}' == identifier,
      orElse: () => pairs.firstWhere((p) => p.tickerId.contains(identifier), orElse: () => pairs.first),
    );
  }
}
