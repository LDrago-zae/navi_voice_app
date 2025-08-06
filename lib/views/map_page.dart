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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: mapController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Start Navigation'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Consumer<MapController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
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
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: SearchWidget(
                    onSearch: controller.searchPlaces,
                    onSelect: controller.selectDestination,
                    searchResults: controller.state.searchResults,
                    controller: _searchController,
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
                        FloatingActionButton.extended(
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

                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => NavigationPage(
                              //       destination: destination,
                              //       useEmbeddedNavigation: true,
                              //     ),
                              //   ),
                              // );
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
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.extended(
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

                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => NavigationPage(
                              //       destination: destination,
                              //       useEmbeddedNavigation: false,
                              //     ),
                              //   ),
                              // );
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
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 100,
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
