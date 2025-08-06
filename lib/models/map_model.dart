import 'package:mapbox_search/models/predictions.dart';

import 'location_model.dart';

class MapState {
  final LocationModel? currentLocation;
  final MapBoxPlace? selectedDestination;
  final List<MapBoxPlace>? searchResults;
  final bool isRouteDrawn;

  MapState({
    this.currentLocation,
    this.selectedDestination,
    this.searchResults,
    this.isRouteDrawn = false,
  });

  MapState copyWith({
    LocationModel? currentLocation,
    MapBoxPlace? selectedDestination,
    List<MapBoxPlace>? searchResults,
    bool? isRouteDrawn,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      searchResults: searchResults ?? this.searchResults,
      isRouteDrawn: isRouteDrawn ?? this.isRouteDrawn,
    );
  }
}