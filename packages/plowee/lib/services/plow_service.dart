import 'package:google_maps_flutter/google_maps_flutter.dart';

class Plow {
final String id;
final LatLng location;
final String status;

Plow({
    required this.id,
    required this.location,
    required this.status,
});
}

class PlowService {
// Static list of plows for initial implementation
List<Plow> getNearbyPlows(LatLng center) {
    // Return static plows around the given center point
    return [
    Plow(
        id: 'plow1',
        location: LatLng(
        center.latitude + 0.001, 
        center.longitude + 0.001
        ),
        status: 'active',
    ),
    Plow(
        id: 'plow2',
        location: LatLng(
        center.latitude - 0.002, 
        center.longitude + 0.002
        ),
        status: 'active',
    ),
    Plow(
        id: 'plow3',
        location: LatLng(
        center.latitude + 0.002, 
        center.longitude - 0.001
        ),
        status: 'active',
    ),
    ];
}

// Method stub for future real-time updates
Stream<List<Plow>> getPlowUpdates(LatLng center) async* {
    // This will be implemented with real-time data later
    yield getNearbyPlows(center);
}
}

