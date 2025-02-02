import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../widgets/action_buttons.dart';
import '../services/location_service.dart';
import '../widgets/custom_map_pin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _locationSubscription;
  BitmapDescriptor? _customMarker;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMarker();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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
    final customIcon = await createCustomMarkerBitmap();

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
    });
    _centerOnLocation();
  }

  Future<void> _centerOnLocation() async {
    if (_currentLocation != null) {
      await _mapController.animateCamera(
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
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _applyCustomMapStyle();
          _initializeLocation();
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

  Future<void> _applyCustomMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _mapController.setMapStyle(style);
  }
}
