import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../widgets/action_buttons.dart';
import '../services/location_service.dart';
import '../widgets/custom_map_pin.dart';
import '../services/plow_service.dart';
import '../services/ice_spot_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  GoogleMapController? _mapController; // Change from late to nullable
  final LocationService _locationService = LocationService();
  final PlowService _plowService = PlowService();
  final IceSpotService _iceSpotService = IceSpotService();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  Set<Marker> _plowMarkers = {};
  Set<Polyline> _iceSpots = {};
  StreamSubscription<Position>? _locationSubscription;
  BitmapDescriptor? _customMarker;
  BitmapDescriptor? _plowMarker;
  Timer? _plowUpdateTimer;
  late AnimationController _pulseController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      // Add this
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
    WidgetsBinding.instance.addObserver(this);
    _initializeMarker();
    _initializeLocation();
    _startPlowUpdates();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationSubscription?.cancel();
    _plowUpdateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeMarker() async {
    _customMarker = await createCustomMarkerBitmap();
    _plowMarker =
        await BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentLocation();
      _updateLocation(position!);
      _startLocationUpdates();
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = _locationService.getLocationStream().listen(
      _updateLocation,
      onError: (error) {
        // Handle error state
        debugPrint('Location updates error: $error');
      },
    );
  }

  void _updateLocation(Position position) async {
    final newLocation = LatLng(position.latitude, position.longitude);
    final customIcon = await createCustomMarkerBitmap(_pulseController.value);

    setState(() {
      _currentLocation = newLocation;
      _markers = {
        Marker(
          markerId: const MarkerId('user_location'),
          position: newLocation,
          icon: customIcon,
          anchor: const Offset(0.5, 0.5),
        ),
      };
      _updatePlowMarkers(newLocation);
      _updateIceSpots(newLocation);
    });
    if (_mapController != null) {
      // Add null check here
      _centerOnLocation();
    }
  }

  Future<void> _centerOnLocation() async {
    if (_currentLocation != null && _mapController != null) {
      // Add null check
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController = controller;
              });
              _applyCustomMapStyle();
              _initializeLocation();
            },
            markers: _markers.union(_plowMarkers),
            polylines: _iceSpots,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const ActionButtons(),
    );
  }

  void _startPlowUpdates() {
// Update plow locations every 5 seconds
    _plowUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentLocation != null) {
        _updatePlowMarkers(_currentLocation!);
      }
    });
  }

  void _updatePlowMarkers(LatLng center) {
    final plows = _plowService.getNearbyPlows(center);
    setState(() {
      _plowMarkers = plows
          .map((plow) => Marker(
                markerId: MarkerId(plow.id),
                position: plow.location,
                icon: _plowMarker ??
                    BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet),
                anchor: const Offset(0.5, 0.5),
              ))
          .toSet();
    });
  }

  void _updateIceSpots(LatLng center) {
    final iceSpots = _iceSpotService.getNearbyIceSpots(center);
    setState(() {
      _iceSpots = iceSpots
          .map((spot) => Polyline(
                polylineId: PolylineId(spot.id),
                points: spot.points,
                color: Colors.blue.withOpacity(0.5),
                width: 8,
              ))
          .toSet();
    });
  }

  Future<void> _applyCustomMapStyle() async {
    if (_mapController == null) return; // Add null check
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    await _mapController!.setMapStyle(style);
  }
}
