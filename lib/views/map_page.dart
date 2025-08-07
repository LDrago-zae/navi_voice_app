import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:navi_voice_app/views/profile_page.dart';
import 'package:navi_voice_app/views/voice_packs_page.dart';
import 'package:navi_voice_app/views/widgets/custom_bottom_nav.dart';
import 'package:navi_voice_app/views/widgets/route_button.dart';
import 'package:navi_voice_app/views/widgets/search_button.dart';
import 'package:provider/provider.dart';
import '../controllers/location_controller.dart';
import '../controllers/map_controller.dart';
import '../services/direction_service.dart';
import '../services/geolocation_service.dart';
import '../services/mapbox_service.dart';
import '../models/location_model.dart';
import '../services/ors_service.dart';

import 'home_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _selectedIndex = 1;
  bool isDark = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // Stay on Maps page (current page)
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VoicePacksPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              isDark: isDark,
              onThemeChanged: (bool value) {
                setState(() {
                  isDark = value;
                });
              },
            ),
          ),
        );
        break;
    }
  }

  late final MapController mapController;
  late final LocationController _locationController;
  final TextEditingController _searchController = TextEditingController();
  PointAnnotationManager? pointAnnotationManager;
  bool _initialCameraSet = false;

  // ORS and TTS
  late final ORSService _orsService;
  late final NavigationTTS _navigationTTS;
  List<dynamic> _navigationSteps = [];
  int _currentStepIndex = 0;
  String? _currentInstruction;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    final mapboxService = MapboxService(dotenv.env['MAP_BOX_ACCESS_TOKEN']!);
    final directionsService = DirectionsService(
      dotenv.env['MAP_BOX_ACCESS_TOKEN']!,
    );
    final geolocationService = GeolocationService();

    mapController = MapController(mapboxService, directionsService);
    _locationController = LocationController(geolocationService);

    // Initialize ORS and TTS
    _orsService = ORSService(dotenv.env['ORS_API_KEY'] ?? '');
    _navigationTTS = NavigationTTS();

    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final location = await _locationController.getCurrentLocation();
      mapController.updateCurrentLocation(location);

      if (mapController.mapboxMap != null && !_initialCameraSet) {
        await mapController.centerToCurrentLocation();
        _initialCameraSet = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    mapController.mapboxMap = mapboxMap;

    if (mapController.state.currentLocation != null && !_initialCameraSet) {
      mapController.centerToCurrentLocation();
      _initialCameraSet = true;
    }
  }

  Future<void> _startNavigationWithVoice(LocationModel destination) async {
    setState(() {
      _isNavigating = true;
      _navigationSteps = [];
      _currentStepIndex = 0;
      _currentInstruction = null;
    });
    try {
      final currentLoc = mapController.state.currentLocation;
      if (currentLoc == null) throw Exception('Current location not available');
      final steps = await _orsService.getRouteSteps(
        startLat: currentLoc.latitude,
        startLng: currentLoc.longitude,
        endLat: destination.latitude,
        endLng: destination.longitude,
      );
      setState(() {
        _navigationSteps = steps;
        _currentStepIndex = 0;
        _currentInstruction = steps.isNotEmpty ? steps[0]['instruction'] : null;
      });
      if (_currentInstruction != null) {
        await _navigationTTS.speak(_currentInstruction!);
      }
    } catch (e) {
      setState(() {
        _isNavigating = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
    }
  }

  void _nextNavigationStep() async {
    if (_navigationSteps.isEmpty) return;
    if (_currentStepIndex + 1 < _navigationSteps.length) {
      setState(() {
        _currentStepIndex++;
        _currentInstruction =
            _navigationSteps[_currentStepIndex]['instruction'];
      });
      await _navigationTTS.speak(_currentInstruction!);
    } else {
      setState(() {
        _isNavigating = false;
        _navigationSteps = [];
        _currentInstruction = null;
        _currentStepIndex = 0;
      });
      await _navigationTTS.speak('You have arrived at your destination.');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: mapController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Start Navigation'),
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
        ),
        body: Consumer<MapController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                // Gradient background behind the map for a modern look
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFede7f6), // light purple
                        Color(0xFFe3f2fd), // light blue
                      ],
                    ),
                  ),
                ),
                MapWidget(
                  textureView: true,
                  onMapCreated: _onMapCreated,
                  cameraOptions: CameraOptions(
                    center: controller.state.currentLocation != null
                        ? Point(
                            coordinates: Position(
                              controller.state.currentLocation!.longitude,
                              controller.state.currentLocation!.latitude,
                            ),
                          )
                        : Point(coordinates: Position(0, 0)),
                    zoom: controller.state.currentLocation != null ? 15 : 2,
                  ),
                  styleUri: MapboxStyles.MAPBOX_STREETS,
                ),
                // Styled search bar
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 4.0,
                      ),
                      child: SearchWidget(
                        onSearch: controller.searchPlaces,
                        onSelect: controller.selectDestination,
                        searchResults: controller.state.searchResults,
                        controller: _searchController,
                      ),
                    ),
                  ),
                ),
                RouteButton(
                  onPressed: () async {
                    try {
                      await controller.drawRoute();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error drawing route: $e')),
                      );
                    }
                  },
                  isVisible: controller.state.selectedDestination != null,
                ),
                // Navigation button
                if (controller.state.selectedDestination != null)
                  Positioned(
                    bottom: 120,
                    right: 16,
                    child: Column(
                      children: [
                        // Embedded navigation button with shadow and rounded corners
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FloatingActionButton.extended(
                            heroTag: "navigate_embedded",
                            onPressed: () async {
                              try {
                                final destination = LocationModel(
                                  latitude: controller
                                      .state
                                      .selectedDestination!
                                      .center!
                                      .lat,
                                  longitude: controller
                                      .state
                                      .selectedDestination!
                                      .center!
                                      .long,
                                  name:
                                      controller
                                          .state
                                          .selectedDestination!
                                          .placeName ??
                                      "Destination",
                                );
                                await _startNavigationWithVoice(destination);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error starting navigation: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            label: const Text('Navigate'),
                            icon: const Icon(Icons.navigation),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Full navigation button with shadow and rounded corners
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FloatingActionButton.extended(
                            heroTag: "navigate_fullscreen",
                            onPressed: () async {
                              try {
                                final destination = LocationModel(
                                  latitude: controller
                                      .state
                                      .selectedDestination!
                                      .center!
                                      .lat,
                                  longitude: controller
                                      .state
                                      .selectedDestination!
                                      .center!
                                      .long,
                                  name:
                                      controller
                                          .state
                                          .selectedDestination!
                                          .placeName ??
                                      "Destination",
                                );
                                // Navigation logic here
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error starting navigation: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            label: const Text('Full Nav'),
                            icon: const Icon(Icons.fullscreen),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isNavigating && _currentInstruction != null)
                  Positioned(
                    bottom: 200,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Navigation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentInstruction!,
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _nextNavigationStep,
                              icon: Icon(Icons.arrow_forward),
                              label: Text('Next Step'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () async {
              try {
                await mapController.centerToCurrentLocation();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error centering: $e')));
              }
            },
            backgroundColor: Colors.deepPurpleAccent,
            child: const Icon(Icons.my_location),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          isDark: isDark,
        ),
      ),
    );
  }
}
