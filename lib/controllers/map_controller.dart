import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/models/location.dart';
import 'package:mapbox_search/models/predictions.dart';
import '../models/location_model.dart';
import '../services/direction_service.dart';
import '../services/mapbox_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MapController extends ChangeNotifier {
  final MapboxService _mapboxService;
  final DirectionsService _directionsService;
  MapboxMap? mapboxMap;
  PointAnnotationManager? _pointAnnotationManager; // Store the manager

  MapState _state = MapState();
  MapState get state => _state;

  MapController(this._mapboxService, this._directionsService);

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      _state = _state.copyWith(searchResults: null);
      notifyListeners();
      return;
    }

    // Get current location for proximity bias
    final currentLoc = _state.currentLocation;
    String proximityParam = '';
    if (currentLoc != null) {
      proximityParam =
          '&proximity=${currentLoc.longitude},${currentLoc.latitude}';
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=${_mapboxService.apiKey}&types=poi,address,place&limit=10&language=en$proximityParam',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        // Filter for multi-word queries: show results containing all words
        final lowerQuery = query.toLowerCase();
        final queryWords = lowerQuery
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();
        final results = features
            .map((feature) => MapBoxPlace.fromJson(feature))
            .where((place) {
              final name = place.placeName?.toLowerCase() ?? '';
              // All query words must be present in the name (partial match)
              return queryWords.every((word) => name.contains(word));
            })
            .toList();
        _state = _state.copyWith(searchResults: results);
        notifyListeners();
      }
    } catch (e) {
      print('Search error: $e');
    }
  }

  void selectDestination(MapBoxPlace place) {
    _state = _state.copyWith(selectedDestination: place, searchResults: null);
    notifyListeners();

    // Move camera to selected destination
    mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(place.center!.long, place.center!.lat),
        ),
        zoom: 12,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> drawRoute() async {
    if (_state.currentLocation == null || _state.selectedDestination == null) {
      throw Exception('Current location or destination not set');
    }

    final start = LatLng(
      _state.currentLocation!.latitude,
      _state.currentLocation!.longitude,
    );
    final end = LatLng(
      _state.selectedDestination!.center!.lat,
      _state.selectedDestination!.center!.long,
    );

    final coordinates = await _directionsService.getRouteCoordinates(
      start,
      end,
    );
    _state = _state.copyWith(isRouteDrawn: true);
    notifyListeners();

    // Draw route on map
    if (mapboxMap != null) {
      final routeFeature = Feature(
        id: "route",
        geometry: LineString(
          coordinates: coordinates
              .map((latLng) => Position(latLng.longitude, latLng.latitude))
              .toList(),
        ),
      );

      await mapboxMap!.style.addSource(
        GeoJsonSource(
          id: "route",
          data: jsonEncode(FeatureCollection(features: [routeFeature])),
        ),
      );

      await mapboxMap!.style.addLayer(
        LineLayer(
          id: "route_layer",
          sourceId: "route",
          lineColor: Colors.blue.toARGB32(),
          lineWidth: 5.0,
        ),
      );
    }
  }

  Future<void> centerToCurrentLocation() async {
    if (_state.currentLocation != null && mapboxMap != null) {
      await mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _state.currentLocation!.longitude,
              _state.currentLocation!.latitude,
            ),
          ),
          zoom: 15,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  void updateCurrentLocation(LocationModel location) {
    // Optional: Check if location has significantly changed to avoid unnecessary updates
    if (_state.currentLocation != null) {
      const double threshold = 0.0001; // ~10 meters
      final latDiff = (location.latitude - _state.currentLocation!.latitude)
          .abs();
      final lonDiff = (location.longitude - _state.currentLocation!.longitude)
          .abs();
      if (latDiff < threshold && lonDiff < threshold) {
        print('MapController: Location update skipped (within threshold)');
        return;
      }
    }

    _state = _state.copyWith(currentLocation: location);
    notifyListeners();
    _updateCurrentLocationMarker();
  }

  Future<void> _updateCurrentLocationMarker() async {
    if (mapboxMap == null || _state.currentLocation == null) {
      print('MapController: Skipping marker update (map or location null)');
      return;
    }

    // Initialize PointAnnotationManager if not already done
    if (_pointAnnotationManager == null) {
      _pointAnnotationManager = await mapboxMap!.annotations
          .createPointAnnotationManager();
      print('MapController: Created PointAnnotationManager');
    }

    // Clear existing markers
    await _pointAnnotationManager!.deleteAll();
    print('MapController: Cleared existing markers');

    // Load marker image
    final ByteData bytes = await rootBundle.load('assets/icons/marker.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Add new marker
    await _pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            _state.currentLocation!.longitude,
            _state.currentLocation!.latitude,
          ),
        ),
        image: imageData,
        iconSize: 2.5,
      ),
    );
    print(
      'MapController: Added new marker at (${_state.currentLocation!.latitude}, ${_state.currentLocation!.longitude})',
    );
  }

  @override
  void dispose() {
    _pointAnnotationManager?.deleteAll();
    _pointAnnotationManager = null;
    super.dispose();
  }
}

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
