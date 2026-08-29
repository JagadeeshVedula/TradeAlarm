import requests
from decimal import Decimal

API_URL = "https://arbitrum-api.gmxinfra.io/markets/info"
TARGET_MARKET = "0x09400D9DB990D5ed3f35D7be61DfAEB900Af03C9".lower()

data = requests.get(API_URL, timeout=20).json()

# API response is normally: {"markets": [...]}
markets = data["markets"] if isinstance(data, dict) else data

market = next(
    (
        m for m in markets
        if m.get("marketToken", "").lower() == TARGET_MARKET
    ),
    None,
)

if market is None:
    raise RuntimeError("SOL/USD [SOL-USDC] market not found")

long_oi = Decimal(market["openInterestLong"])
short_oi = Decimal(market["openInterestShort"])
total_oi = long_oi + short_oi

long_pct = long_oi / total_oi * Decimal("100")
short_pct = short_oi / total_oi * Decimal("100")

print("Market:", market["name"])
print("Market token:", market["marketToken"])
print("Index token:", market["indexToken"])
print("Long token:", market["longToken"])
print("Short token:", market["shortToken"])
print()
print("Long OI:", long_oi / Decimal(10**30))
print("Short OI:", short_oi / Decimal(10**30))
print("Long percentage:", round(long_pct, 2), "%")
print("Short percentage:", round(short_pct, 2), "%")
