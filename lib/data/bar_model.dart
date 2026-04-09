// lib/data/bar_model.dart
// Shared Bar data model + nearest-neighbour route optimizer.
import 'dart:math' as math;

class Bar {
  final String name;
  final String neighborhood;
  final String borough;     // district / city area
  final String type;
  final String vibe;
  final String drink;
  final int par;
  final String flavorText;
  final double latitude;
  final double longitude;

  const Bar({
    required this.name,
    required this.neighborhood,
    required this.borough,
    required this.type,
    required this.vibe,
    required this.drink,
    required this.par,
    required this.flavorText,
    required this.latitude,
    required this.longitude,
  });

  (String, String) get asRouteTuple => (name, '$neighborhood · $vibe');

  double distanceTo(Bar other) {
    final dlat = latitude - other.latitude;
    final dlng = longitude - other.longitude;
    return math.sqrt(dlat * dlat + dlng * dlng);
  }
}

// ─── Nearest-neighbour TSP heuristic ─────────────────────────────────────────
// Starts from the first bar in [bars] and greedily picks the closest next bar,
// minimising total walking distance for [count] stops.
List<Bar> nearestNeighborRoute(List<Bar> bars, int count) {
  if (bars.isEmpty || count <= 0) return [];
  count = count.clamp(1, bars.length);
  final pool = bars.toList();
  final route = <Bar>[pool.removeAt(0)];
  while (route.length < count && pool.isNotEmpty) {
    final last = route.last;
    int nearestIdx = 0;
    double nearestDist = last.distanceTo(pool[0]);
    for (int i = 1; i < pool.length; i++) {
      final d = last.distanceTo(pool[i]);
      if (d < nearestDist) {
        nearestDist = d;
        nearestIdx = i;
      }
    }
    route.add(pool.removeAt(nearestIdx));
  }
  return route;
}
