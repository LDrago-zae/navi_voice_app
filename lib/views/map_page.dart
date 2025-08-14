import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:navi_voice_app/views/profile_page.dart';
import 'package:navi_voice_app/views/voice_packs_page.dart';
import 'package:navi_voice_app/views/widgets/custom_bottom_nav.dart';
import 'package:navi_voice_app/views/widgets/search_button.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../constants/constants.dart';
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
  int _currentStyleIndex = 0;
  final List<String> _mapStyles = const [
    MapboxStyles.MAPBOX_STREETS,
    MapboxStyles.LIGHT,
    MapboxStyles.SATELLITE_STREETS,
  ];

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
    return ChangeNotifierProvider.value(
      value: mapController,
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: Consumer<MapController>(
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
                      key: ValueKey(_currentStyleIndex),
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
                      styleUri: _mapStyles[_currentStyleIndex],
                    ),
                    // Top gradient scrim for readability
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.black.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Styled search bar + style switcher in a responsive row
                    Positioned(
                      top: 24.0,
                      left: 16.0,
                      right: 16.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 14,
                                  sigmaY: 14,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                    horizontal: 6.0,
                                  ),
                                  child: SearchWidget(
                                    onSearch: controller.searchPlaces,
                                    onSelect: controller.selectDestination,
                                    searchResults:
                                        controller.state.searchResults,
                                    controller: _searchController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(_mapStyles.length, (
                                    i,
                                  ) {
                                    final isSelected = i == _currentStyleIndex;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => setState(
                                          () => _currentStyleIndex = i,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white.withOpacity(0.28)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            i == 0
                                                ? Icons.map
                                                : i == 1
                                                ? Icons.light_mode
                                                : Icons.satellite_alt,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Navigation button
                    if (controller.state.selectedDestination != null)
                      Positioned(bottom: 120, right: 16, child: Container()),
                    // Bottom draggable sheet for actions / navigation
                    if (controller.state.selectedDestination != null ||
                        (_isNavigating && _currentInstruction != null))
                      DraggableScrollableSheet(
                        initialChildSize: 0.18,
                        minChildSize: 0.12,
                        maxChildSize: 0.4,
                        builder: (context, scrollController) {
                          final destination =
                              controller.state.selectedDestination;
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.getCardColor(isDark),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, -6),
                                ),
                              ],
                            ),
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                10,
                                16,
                                16,
                              ),
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_isNavigating &&
                                    _currentInstruction != null) ...[
                                  Text(
                                    'Navigation',
                                    style: AppStyles.h5.copyWith(
                                      color: AppColors.getTextPrimary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentInstruction!,
                                    style: AppStyles.t3Small.copyWith(
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _nextNavigationStep,
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text('Next Step'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.accent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (destination != null) ...[
                                  Text(
                                    destination.placeName ??
                                        'Selected destination',
                                    style: AppStyles.h5.copyWith(
                                      color: AppColors.getTextPrimary(isDark),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  if (destination.address != null)
                                    Text(
                                      destination.address!,
                                      style: AppStyles.t3Small.copyWith(
                                        color: AppColors.getTextSecondary(
                                          isDark,
                                        ),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              await controller.drawRoute();
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error drawing route: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.alt_route),
                                          label: const Text('Route'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              final dest = LocationModel(
                                                latitude:
                                                    destination.center!.lat,
                                                longitude:
                                                    destination.center!.long,
                                                name:
                                                    destination.placeName ??
                                                    'Destination',
                                              );
                                              await _startNavigationWithVoice(
                                                dest,
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error starting navigation: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.navigation),
                                          label: const Text('Navigate'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error centering: $e')),
                      );
                    }
                  },
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.my_location),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
                      // Placeholder for future action (e.g., traffic toggle)
                    } catch (_) {}
                  },
                  backgroundColor: AppColors.getPrimary(isDark),
                  child: const Icon(Icons.layers),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}
