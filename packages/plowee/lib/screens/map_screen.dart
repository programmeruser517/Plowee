import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/action_buttons.dart';
import '../services/location_service.dart';
import '../widgets/custom_map_pin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _locationSubscription;
  BitmapDescriptor? _customMarker;
  late AnimationController _pulseController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeLocation();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController.addListener(() {
      _updateMarkerWithPulse();
    });
  }

  void _updateMarkerWithPulse() {
    if (_customMarker != null) {
      final pulse = _pulseController.value;
      final customIcon = CustomMapPin(
        dotColor: Colors.blue,
        pulse: pulse,
      );
      final bitmap = customIcon.toBitmap();
      setState(() {
        _customMarker = BitmapDescriptor.fromBytes(bitmap as Uint8List);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMarker() async {
    _customMarker = await createCustomMarkerBitmap();
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
    _customMarker ??= await createCustomMarkerBitmap();
    setState(() {
      _currentLocation = newLocation;
      _markers = {
        Marker(
          markerId: const MarkerId('user_location'),
          position: newLocation,
          icon: _customMarker!,
          anchor: const Offset(0.5, 0.5),
        ),
      };
    });

    if (_mapController != null) {
      _centerOnLocation();
    }
  }

  Future<void> _centerOnLocation() async {
    if (_currentLocation != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _currentLocation!,
          15,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
            if (_currentLocation != null) {
              _centerOnLocation();
            }
          });
        },
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const ActionButtons(),
    );
  }
}
