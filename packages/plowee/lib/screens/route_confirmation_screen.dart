import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';
import '../services/location_service.dart';
import '../services/directions_service.dart';

class RouteConfirmationScreen extends StatefulWidget {
  final String destinationAddress;

  const RouteConfirmationScreen({
    super.key,
    required this.destinationAddress,
  });

  @override
  State<RouteConfirmationScreen> createState() =>
      _RouteConfirmationScreenState();
}

class _RouteConfirmationScreenState extends State<RouteConfirmationScreen> {
  final _placesService =
      PlacesService("AIzaSyCcEEXbsnVt9ESSxQmPDImXuEtjl9VkP3M");
  final _directionsService =
      DirectionsService("AIzaSyCcEEXbsnVt9ESSxQmPDImXuEtjl9VkP3M");
  final _locationService = LocationService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

Future<void> _initializeLocations() async {
if (!mounted) return;

try {
    // Get all required data first
    final currentLocation = await _locationService.getCurrentLocation();
    final coordinates = await _placesService.getCoordinatesFromAddress(
    widget.destinationAddress,
    );

    if (!mounted) return;

    final currentLatLng = currentLocation != null
        ? LatLng(currentLocation.latitude, currentLocation.longitude)
        : null;

    // Only proceed if we have both locations
    if (currentLatLng == null || coordinates == null) {
    setState(() {
        _error = 'Could not get location data';
        _isLoading = false;
    });
    return;
    }

    // Get route points
    final routePoints = await _directionsService.getDirections(
    currentLatLng,
    coordinates,
    );

    if (!mounted) return;

    // Update state with all data at once
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
        Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 4,
        ),
    };
    _isLoading = false;
    });

    _fitBounds();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _buildMapContent(),
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_destinationLocation == null) {
      return const Center(child: Text('Could not find location'));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _destinationLocation ?? const LatLng(0, 0),
        zoom: 15,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _mapController = controller;
        _fitBounds();
      },
    );
  }
}
