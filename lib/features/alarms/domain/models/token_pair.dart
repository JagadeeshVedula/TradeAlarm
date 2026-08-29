class TokenPair {
  final String tickerId;
  final String baseCurrency;
  final String targetCurrency;
  final double lastPrice;
  final double volumeUsd;
  final double longOpenInterestUsd;
  final double shortOpenInterestUsd;
  final String? marketToken;

  final bool hasValidOiData;

  TokenPair({
    required this.tickerId,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.lastPrice,
    required this.volumeUsd,
    required this.longOpenInterestUsd,
    required this.shortOpenInterestUsd,
    this.marketToken,
    this.hasValidOiData = true,
  });

  double get totalOpenInterestUsd => longOpenInterestUsd + shortOpenInterestUsd;

  double get longPct {
    if (totalOpenInterestUsd <= 0) return 50.0;
    return (longOpenInterestUsd / totalOpenInterestUsd) * 100.0;
  }

  double get shortPct => 100.0 - longPct;

  bool get isValidPerp => totalOpenInterestUsd > 0 && hasValidOiData;

  factory TokenPair.fromMarketInfoJson(
    Map<String, dynamic> json, {
    double lastPrice = 0.0,
    double volumeUsd = 0.0,
  }) {
    double parseOi(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble() / 1e30;
      final str = val.toString().trim();
      if (str.isEmpty) return 0.0;
      final d = double.tryParse(str);
      if (d != null) return d / 1e30;
      return 0.0;
    }

    final name = json['name']?.toString() ?? '';
    final mToken = json['marketToken']?.toString();

    String baseCurrency = '';
    if (name.contains('/')) {
      baseCurrency = name.split('/')[0].trim();
    } else if (name.contains('-')) {
      baseCurrency = name.split('-')[0].trim();
    } else {
      baseCurrency = name;
    }

    final loi = parseOi(json['openInterestLong']);
    final soi = parseOi(json['openInterestShort']);
    final hasOi = (loi + soi) > 0;

    return TokenPair(
      tickerId: name,
      baseCurrency: baseCurrency,
      targetCurrency: 'USD',
      lastPrice: lastPrice,
      volumeUsd: volumeUsd,
      longOpenInterestUsd: loi,
      shortOpenInterestUsd: soi,
      marketToken: mToken,
      hasValidOiData: hasOi,
    );
  }

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final hasValidOi = json['long_open_interest'] != null && json['short_open_interest'] != null;

    return TokenPair(
      tickerId: json['ticker_id']?.toString() ?? '',
      baseCurrency: json['base_currency']?.toString() ?? '',
      targetCurrency: json['target_currency']?.toString() ?? 'USD',
      lastPrice: parseDouble(json['last_price']),
      volumeUsd: parseDouble(json['volume_usd']),
      longOpenInterestUsd: parseDouble(json['long_open_interest']),
      shortOpenInterestUsd: parseDouble(json['short_open_interest']),
      marketToken: json['market_token']?.toString(),
      hasValidOiData: hasValidOi,
    );
  }

  Map<String, dynamic> toJson() => {
        'ticker_id': tickerId,
        'base_currency': baseCurrency,
        'target_currency': targetCurrency,
        'last_price': lastPrice,
        'volume_usd': volumeUsd,
        'long_open_interest': longOpenInterestUsd,
        'short_open_interest': shortOpenInterestUsd,
        'market_token': marketToken,
      };
}
