import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';
import '../services/location_service.dart';
import '../services/plow_service.dart';
import '../services/ice_spot_service.dart';
import '../widgets/eta_progress_widget.dart';
import 'dart:async';
import 'dart:math' as math;

class RouteConfirmationScreen extends StatefulWidget {
  final String destinationAddress;
  const RouteConfirmationScreen({
    Key? key,
    required this.destinationAddress,
  }) : super(key: key);

  @override
  State<RouteConfirmationScreen> createState() =>
      _RouteConfirmationScreenState();
}

class _RouteConfirmationScreenState extends State<RouteConfirmationScreen> {
  final _placesService =
      PlacesService("AIzaSyCcEEXbsnVt9ESSxQmPDImXuEtjl9VkP3M");
  final _locationService = LocationService();
  final _plowService = PlowService();
  final _iceSpotService = IceSpotService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Marker> _plowMarkers = {};
  Set<Polyline> _iceSpotPolylines = {};
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  bool _isLoading = true;
  String? _error;
  Timer? _updateTimer;
  int _totalMinutes = 0;
  int _elapsedMinutes = 0;
  Timer? _etaTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && _currentLocation != null) {
        _updatePlowsAndIceSpots();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _etaTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    double lat1 = start.latitude * math.pi / 180;
    double lat2 = end.latitude * math.pi / 180;
    double dLat = (end.latitude - start.latitude) * math.pi / 180;
    double dLon = (end.longitude - start.longitude) * math.pi / 180;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
}

List<LatLng> _generateRoutePath(LatLng start, LatLng end) {
final points = <LatLng>[];
const numPoints = 8; // Number of intermediate points
final random = math.Random();

// Calculate the main direction vector
double dLat = (end.latitude - start.latitude) / (numPoints + 1);
double dLng = (end.longitude - start.longitude) / (numPoints + 1);

// Add start point
points.add(start);

// Generate intermediate points with controlled randomness
for (int i = 1; i <= numPoints; i++) {
    // Base position along the straight line
    double baseLat = start.latitude + (dLat * i);
    double baseLng = start.longitude + (dLng * i);
    
    // Add random variation
    // The variation is larger in the middle and smaller at the ends
    double progress = i / (numPoints + 1);
    double variation = 0.001 * math.sin(progress * math.pi); // Max ~100m deviation
    
    // Random offset, larger perpendicular to the main direction
    double randomLat = (random.nextDouble() - 0.5) * variation;
    double randomLng = (random.nextDouble() - 0.5) * variation;
    
    points.add(LatLng(
    baseLat + randomLat,
    baseLng + randomLng,
    ));
}

// Add end point
points.add(end);

return points;
}

  void _startEtaTimer(double distanceInMeters) {
    const averageSpeedMps = 13.4; // ~30mph in meters/second
    _totalMinutes = (distanceInMeters / averageSpeedMps / 60).round();
    _elapsedMinutes = 0;

    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedMinutes++;
          if (_elapsedMinutes >= _totalMinutes) {
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _initializeLocations() async {
    if (!mounted) return;

    try {
      final currentLocation = await _locationService.getCurrentLocation();
      final coordinates = await _placesService.getCoordinatesFromAddress(
        widget.destinationAddress,
      );

      if (!mounted) return;

      final currentLatLng = currentLocation != null
          ? LatLng(currentLocation.latitude, currentLocation.longitude)
          : null;

      if (currentLatLng == null || coordinates == null) {
        setState(() {
          _error = 'Could not get location data';
          _isLoading = false;
        });
        return;
      }

      // Calculate distance and start ETA timer
      double distance = _calculateDistance(currentLatLng, coordinates);
      _startEtaTimer(distance);

      setState(() {
        _currentLocation = currentLatLng;
        _destinationLocation = coordinates;
        _markers = {
          Marker(
            markerId: const MarkerId('current'),
            position: currentLatLng,
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: coordinates,
            infoWindow: InfoWindow(title: widget.destinationAddress),
          ),
        };
        _polylines = {
        // Generate a natural-looking path
        Polyline(
            polylineId: const PolylineId('route'),
            points: _generateRoutePath(currentLatLng, coordinates),
            color: Colors.blue,
            width: 4,
          ),
        };
        _isLoading = false;
      });

      _fitBounds();
      _updatePlowsAndIceSpots();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _fitBounds() {
    if (_currentLocation != null &&
        _destinationLocation != null &&
        _mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _currentLocation!.latitude < _destinationLocation!.latitude
              ? _currentLocation!.latitude
              : _destinationLocation!.latitude,
          _currentLocation!.longitude < _destinationLocation!.longitude
              ? _currentLocation!.longitude
              : _destinationLocation!.longitude,
        ),
        northeast: LatLng(
          _currentLocation!.latitude > _destinationLocation!.latitude
              ? _currentLocation!.latitude
              : _destinationLocation!.latitude,
          _currentLocation!.longitude > _destinationLocation!.longitude
              ? _currentLocation!.longitude
              : _destinationLocation!.longitude,
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  Future<void> _updatePlowsAndIceSpots() async {
    if (_currentLocation == null) return;

    try {
      final plowLocations =
          await _plowService.getNearbyPlows(_currentLocation!);
      final iceSpots =
          await _iceSpotService.getNearbyIceSpots(_currentLocation!);

      if (!mounted) return;

      setState(() {
        _plowMarkers = plowLocations
            .map((loc) => Marker(
                  markerId: MarkerId('plow_${loc.hashCode}'),
                  position: loc.location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
                      .hueViolet), // Replace with custom plow icon later
                  infoWindow: const InfoWindow(title: 'Plow'),
                ))
            .toSet();

        _iceSpotPolylines = iceSpots
            .map((iceSpot) => Polyline(
                  polylineId: PolylineId('ice_${iceSpot.hashCode}'),
                  points: iceSpot.points,
                  color: Colors.blue.withOpacity(0.5),
                  width: 8,
                ))
            .toSet();
      });
    } catch (e) {
      // Handle error silently - don't update markers/polylines if there's an error
      debugPrint('Error updating plows and ice spots: $e');
    }
  }

  Future<void> _getDestinationCoordinates() async {
    try {
      final coordinates = await _placesService.getCoordinatesFromAddress(
        widget.destinationAddress,
      );

      setState(() {
        _destinationLocation = coordinates!;
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(coordinates!, 15),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Route Confirmation')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Route Confirmation')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _destinationLocation ?? const LatLng(0, 0),
              zoom: 15,
            ),
            markers: {..._markers, ..._plowMarkers},
            polylines: {..._polylines, ..._iceSpotPolylines},
            onMapCreated: (controller) {
              _mapController = controller;
              _fitBounds();
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ETA: ${_totalMinutes - _elapsedMinutes} minutes',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  ETAProgressWidget(
                    totalMinutes: _totalMinutes,
                    elapsedMinutes: _elapsedMinutes,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
