import 'dart:async';
import 'dart:math' as math;
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
import 'dart:ui';
import 'home_page.dart';

// Assuming LocationModel updated to include: double? bearing;
// In LocationController (if not already):
// Stream<LocationModel> get locationStream => geolocationService.location.onLocationChanged.map((data) => LocationModel(
//   latitude: data.latitude!,
//   longitude: data.longitude!,
//   bearing: data.heading,
// ));

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  bool isDark = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    final mapboxService = MapboxService(dotenv.env['MAP_BOX_ACCESS_TOKEN']!);
    final directionsService = DirectionsService(
      dotenv.env['MAP_BOX_ACCESS_TOKEN']!,
    );
    final geolocationService = GeolocationService();

    mapController = MapController(mapboxService, directionsService);
    _locationController = LocationController(geolocationService);

    _orsService = ORSService(dotenv.env['ORS_API_KEY'] ?? '');
    _navigationTTS = NavigationTTS();

    _initializeLocation();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    _locationSub?.cancel();
    super.dispose();
  }

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

  late final ORSService _orsService;
  late final NavigationTTS _navigationTTS;
  List<dynamic> _navigationSteps = [];
  int _currentStepIndex = 0;
  String? _currentInstruction;
  bool _isNavigating = false;
  StreamSubscription<LocationModel>? _locationSub;
  double? _totalDistance; // NEW: Store total route distance in meters

  Future<void> _initializeLocation() async {
    try {
      final location = await _locationController.getCurrentLocation();
      mapController.updateCurrentLocation(location);

      if (mapController.mapboxMap != null && !_initialCameraSet) {
        await mapController.centerToCurrentLocation();
        _initialCameraSet = true;
      }
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    mapController.mapboxMap = mapboxMap;

    // Enable user location puck
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
        // puckBearingSource: PuckBearingSource.HEADING,
        // For 3D puck: locationPuck: LocationPuck(locationPuck3D: LocationPuck3D(modelUri: 'your_model_uri')),
      ),
    );

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
      _totalDistance = null; // NEW: Initialize distance
    });
    _fadeController.forward(); // Animate nav card in

    try {
      final currentLoc = mapController.state.currentLocation;
      if (currentLoc == null) throw Exception('Current location not available');

      // NEW: Assuming ORSService.getRouteDetails returns {'steps': List<dynamic>, 'distance': double}
      // If getRouteSteps only returns steps, sum step['distance'] below
      final routeDetails = await _orsService.getRouteSteps(
        startLat: currentLoc.latitude,
        startLng: currentLoc.longitude,
        endLat: destination.latitude,
        endLng: destination.longitude,
      );
      setState(() {
        _navigationSteps = routeDetails ?? [];
        _totalDistance = _navigationSteps.fold<double>(
          0.0,
          (sum, step) => sum + (step['distance'] ?? 0.0),
        );
        _currentStepIndex = 0;
        _currentInstruction = _navigationSteps.isNotEmpty
            ? _navigationSteps[0]['instruction']
            : null;
      });
      if (_currentInstruction != null) {
        await _navigationTTS.speak(_currentInstruction!);
      }

      // Alternative if getRouteDetails not available:
      // final steps = await _orsService.getRouteSteps(...);
      // double totalDist = steps.fold(0.0, (sum, step) => sum + (step['distance'] ?? 0.0));
      // setState(() {
      //   _navigationSteps = steps;
      //   _totalDistance = totalDist;
      //   ...
      // });

      // Start listening to location for camera follow and step progress
      _locationSub = _locationController.locationStream.listen((
        location,
      ) async {
        mapController.updateCurrentLocation(location);

        // Smooth camera follow with tilt and bearing
        await mapController.mapboxMap?.easeTo(
          CameraOptions(
            center: Point(
              coordinates: Position(location.longitude, location.latitude),
            ),
            zoom: 17.0,
            bearing: location.bearing ?? 0.0,
            pitch: 60.0,
          ),
          MapAnimationOptions(duration: 1000),
        );

        // Optional: Log for analytics (e.g., send to Firebase)
        // analytics.logEvent(name: 'location_update', parameters: {'lat': location.latitude, 'lng': location.longitude});

        // Check navigation progress
        if (_navigationSteps.isNotEmpty &&
            _currentStepIndex < _navigationSteps.length) {
          final nextManeuver =
              _navigationSteps[_currentStepIndex]['maneuver']['location']; // [lng, lat]
          final dist = _calculateDistance(
            location.latitude,
            location.longitude,
            nextManeuver[1], // lat
            nextManeuver[0], // lng
          );
          if (dist < 30.0) {
            // Threshold in meters
            _nextNavigationStep();
          }
        }
      });
    } catch (e) {
      _stopNavigation();
      _showSnackBar('Error starting navigation: $e');
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
      _stopNavigation();
      await _navigationTTS.speak('You have arrived at your destination.');
    }
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _navigationSteps = [];
      _currentInstruction = null;
      _currentStepIndex = 0;
      _totalDistance = null; // NEW: Reset distance
    });
    _fadeController.reverse();
    _locationSub?.cancel();
    // Reset camera to default if needed
    mapController.centerToCurrentLocation();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // Earth radius in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildGlassMorphicContainer({
    required Widget child,
    double blur = 10,
    double opacity = 0.1,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: _buildGlassMorphicContainer(
        opacity: 0.15,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SearchWidget(
            onSearch: (query) {
              if (query.isNotEmpty) {
                mapController.searchPlaces(query);
              } else {
                mapController.state.searchResults?.clear();
                setState(() {});
              }
            },
            onSelect: (selectedLocation) {
              _searchController.text = selectedLocation.placeName ?? '';
              mapController.selectDestination(selectedLocation);
              mapController.state.searchResults?.clear();
              FocusScope.of(context).unfocus();
              setState(() {});
            },
            searchResults: mapController.state.searchResults,
            controller: _searchController,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mapController.state.selectedDestination != null) ...[
            _buildGlassMorphicContainer(
              opacity: 0.2,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: FloatingActionButton.extended(
                  heroTag: "route",
                  onPressed: () async {
                    try {
                      await mapController.drawRoute();
                    } catch (e) {
                      _showSnackBar('Error drawing route: $e');
                    }
                  },
                  label: const Text(
                    'Show Route',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Icons.route),
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildGlassMorphicContainer(
              opacity: 0.2,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: FloatingActionButton.extended(
                  heroTag: "navigate",
                  onPressed: () async {
                    try {
                      final destination = LocationModel(
                        latitude: mapController
                            .state
                            .selectedDestination!
                            .center!
                            .lat,
                        longitude: mapController
                            .state
                            .selectedDestination!
                            .center!
                            .long,
                        name:
                            mapController
                                .state
                                .selectedDestination!
                                .placeName ??
                            "Destination",
                      );
                      await _startNavigationWithVoice(destination);
                    } catch (e) {
                      _showSnackBar('Error starting navigation: $e');
                    }
                  },
                  label: const Text(
                    'Navigate',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Icons.navigation),
                  backgroundColor: const Color(0xFF00D4AA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildGlassMorphicContainer(
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: FloatingActionButton(
                      heroTag: "location",
                      onPressed: () async {
                        try {
                          await mapController.centerToCurrentLocation();
                        } catch (e) {
                          _showSnackBar('Error centering: $e');
                        }
                      },
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      child: const Icon(Icons.my_location, size: 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard() {
    // NEW: Format total distance in kilometers
    final distanceKm = _totalDistance != null
        ? (_totalDistance! / 1000).toStringAsFixed(1)
        : 'Calculating';
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassMorphicContainer(
        opacity: 0.15,
        blur: 15,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Navigation Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // NEW: Display estimated distance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.straighten, color: Colors.black54, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated distance: $distanceKm km',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _currentInstruction ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _stopNavigation,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text(
                    'Stop Navigation',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: mapController,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _buildGlassMorphicContainer(
            opacity: 0.1,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Navigation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<MapController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                // Map with modern styling
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
                  styleUri: isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT,
                ),

                // Conditional UI based on navigation state
                if (!_isNavigating) ...[
                  // Modern search bar
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: _buildModernSearchBar(),
                  ),

                  // Action buttons
                  Positioned(
                    bottom: 120,
                    right: 16,
                    child: _buildActionButtons(),
                  ),
                ],

                // Navigation dialog (top-positioned)
                if (_isNavigating && _currentInstruction != null)
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: _buildNavigationCard(),
                  ),
              ],
            );
          },
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
