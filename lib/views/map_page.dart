import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:navi_voice_app/models/voice_pack.dart';
import 'package:navi_voice_app/services/navigation_tts.dart';
import 'package:navi_voice_app/views/home_page.dart';
import 'package:navi_voice_app/views/widgets/custom_bottom_nav.dart';
import 'package:navi_voice_app/views/widgets/search_button.dart';
import 'package:navi_voice_app/views/profile_page.dart';
import 'package:provider/provider.dart';
import '../controllers/location_controller.dart';
import '../controllers/map_controller.dart';
import '../services/direction_service.dart';
import '../services/geolocation_service.dart';
import '../services/mapbox_service.dart';
import '../models/location_model.dart';
import '../services/ors_service.dart';
import '../views/voice_packs_page.dart';

class MapPage extends StatefulWidget {
  final VoicePack? selectedVoice;
  const MapPage({super.key, this.selectedVoice});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  bool isDark = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  VoicePack? _selectedVoice;
  final int _selectedIndex = 1; // MapPage index

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VoicePacksPage(isDark: isDark)),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            isDark: isDark,
            onThemeChanged: (value) {
              setState(() {
                isDark = value;
              });
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedVoice = widget.selectedVoice;
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
    _navigationTTS = NavigationTTS(dotenv.env['ELEVENLABS_API_KEY'] ?? '');

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
    _navigationTTS.dispose();
    super.dispose();
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
  double? _totalDistance;

  Future<void> _initializeLocation() async {
    try {
      final location = await _locationController.getCurrentLocation();
      // Get location name using reverse geocoding
      final locationWithName = await _getLocationWithName(location);
      mapController.updateCurrentLocation(locationWithName);
      if (mapController.mapboxMap != null && !_initialCameraSet) {
        await mapController.centerToCurrentLocation();
        _initialCameraSet = true;
      }
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    }
  }

  Future<LocationModel> _getLocationWithName(LocationModel location) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${location.longitude},${location.latitude}.json?access_token=${dotenv.env['MAP_BOX_ACCESS_TOKEN']}&types=poi,address,place&limit=1&language=en',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          final placeName = features[0]['place_name'] as String?;
          if (placeName != null) {
            // Extract just the main part of the address (before the first comma)
            final mainLocation = placeName.split(',')[0];
            return LocationModel(
              latitude: location.latitude,
              longitude: location.longitude,
              name: mainLocation,
              bearing: location.bearing,
            );
          }
        }
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }

    // Return original location if reverse geocoding fails
    return location;
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    mapController.mapboxMap = mapboxMap;
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
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
      _totalDistance = null;
    });
    _fadeController.forward();

    try {
      final currentLoc = mapController.state.currentLocation;
      if (currentLoc == null) throw Exception('Current location not available');

      final routeDetails = await _orsService.getRouteSteps(
        startLat: currentLoc.latitude,
        startLng: currentLoc.longitude,
        endLat: destination.latitude,
        endLng: destination.longitude,
      );
      setState(() {
        _navigationSteps = routeDetails;
        _totalDistance = _navigationSteps.fold<double>(
          0.0,
          (sum, step) => sum + ((step['distance'] as num?)?.toDouble() ?? 0.0),
        );
        _currentStepIndex = 0;
        _currentInstruction = _navigationSteps.isNotEmpty
            ? _navigationSteps[0]['instruction']
            : null;
      });
      if (_currentInstruction != null) {
        try {
          await _navigationTTS.speak(
            _currentInstruction!,
            _selectedVoice?.elevenLabsVoiceId ?? 'pNInz6obpgDQGcFmaJgB',
          );
        } catch (e) {
          _showSnackBar('Error speaking instruction: $e');
        }
      }

      _locationSub = _locationController.locationStream.listen((
        location,
      ) async {
        // Only do reverse geocoding for the first location update or if location name is null
        LocationModel locationWithName;
        if (mapController.state.currentLocation?.name == null) {
          locationWithName = await _getLocationWithName(location);
        } else {
          // Keep the existing name but update coordinates
          locationWithName = LocationModel(
            latitude: location.latitude,
            longitude: location.longitude,
            name: mapController.state.currentLocation?.name,
            bearing: location.bearing,
          );
        }
        mapController.updateCurrentLocation(locationWithName);
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

        if (_navigationSteps.isNotEmpty &&
            _currentStepIndex < _navigationSteps.length) {
          final nextManeuver =
              _navigationSteps[_currentStepIndex]['maneuver']['location'];
          final dist = _calculateDistance(
            location.latitude,
            location.longitude,
            nextManeuver[1],
            nextManeuver[0],
          );
          if (dist < 30.0) {
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
      try {
        await _navigationTTS.speak(
          _currentInstruction!,
          _selectedVoice?.elevenLabsVoiceId ?? 'pNInz6obpgDQGcFmaJgB',
        );
      } catch (e) {
        _showSnackBar('Error speaking instruction: $e');
      }
    } else {
      _stopNavigation();
      try {
        await _navigationTTS.speak(
          'You have arrived at your destination.',
          _selectedVoice?.elevenLabsVoiceId ?? 'pNInz6obpgDQGcFmaJgB',
        );
      } catch (e) {
        _showSnackBar('Error speaking arrival message: $e');
      }
    }
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _navigationSteps = [];
      _currentInstruction = null;
      _currentStepIndex = 0;
      _totalDistance = null;
    });
    _fadeController.reverse();
    _locationSub?.cancel();
    mapController.centerToCurrentLocation();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0;
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
        backgroundColor: Colors.cyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
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
    final distanceKm = _totalDistance != null
        ? (_totalDistance! / 1000).toStringAsFixed(1)
        : 'Calculating';

    // Get current location name
    final currentLocationName =
        mapController.state.currentLocation?.name ?? 'Current Location';
    final destinationName =
        mapController.state.selectedDestination?.placeName ?? 'Destination';

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
              // Current location display
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'From: $currentLocationName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Destination display
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'To: $destinationName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onItemTapped(0); // Navigate to HomePage using bottom nav logic
            },
          ),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.headphones),
              tooltip: 'Select Voice',
              onPressed: () async {
                final selected = await _showVoiceSelectionDialog();
                if (selected != null) {
                  setState(() {
                    _selectedVoice = selected;
                  });
                  _showSnackBar('Voice changed to: ${selected.artist}');
                }
              },
            ),
          ],
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
                  styleUri: isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT,
                ),
                if (!_isNavigating) ...[
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: _buildModernSearchBar(),
                  ),
                  Positioned(
                    bottom: 120,
                    right: 16,
                    child: _buildActionButtons(),
                  ),
                ],
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

  Future<VoicePack?> _showVoiceSelectionDialog() async {
    return showDialog<VoicePack>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Voice'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: VoicePack.allVoicePacks.length,
            itemBuilder: (context, index) {
              final voicePack = VoicePack.allVoicePacks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: voicePack.isPremium
                      ? Colors.amber
                      : Colors.blue,
                  child: Icon(
                    voicePack.isPremium ? Icons.star : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                title: Text(voicePack.artist),
                subtitle: Text(voicePack.description),
                trailing: voicePack.isOwned
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : Text('\$${voicePack.price}'),
                onTap: () {
                  Navigator.pop(context, voicePack);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
