// lib/data/city_data.dart
// Registry of all supported cities and their bar lists.
import 'bar_model.dart';
import 'nyc_bars.dart';
import 'la_bars.dart';
import 'las_vegas_bars.dart';
import 'dallas_bars.dart';
import 'miami_bars.dart';
import 'phoenix_bars.dart';

class CityInfo {
  final String name;
  final String emoji;
  final List<Bar> bars;

  const CityInfo({
    required this.name,
    required this.emoji,
    required this.bars,
  });
}

const List<CityInfo> kSupportedCities = [
  CityInfo(name: 'New York City', emoji: '🗽', bars: kNycBars),
  CityInfo(name: 'Los Angeles',   emoji: '🌴', bars: kLaBars),
  CityInfo(name: 'Las Vegas',     emoji: '🎰', bars: kLasVegasBars),
  CityInfo(name: 'Dallas',        emoji: '🤠', bars: kDallasBars),
  CityInfo(name: 'Miami',         emoji: '🌊', bars: kMiamiBars),
  CityInfo(name: 'Phoenix',       emoji: '☀️', bars: kPhoenixBars),
];

CityInfo? cityByName(String name) {
  try {
    return kSupportedCities.firstWhere((c) => c.name == name);
  } catch (_) {
    return null;
  }
}
