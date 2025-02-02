import 'package:google_maps_flutter/google_maps_flutter.dart';

class IceSpotData {
final String id;
final List<LatLng> points;

IceSpotData({required this.id, required this.points});
}

class IceSpotService {
List<IceSpotData> getNearbyIceSpots(LatLng center) {
    // Static data for demonstration
    return [
    IceSpotData(
        id: 'ice_1',
        points: [
        LatLng(center.latitude + 0.001, center.longitude - 0.001),
        LatLng(center.latitude + 0.002, center.longitude - 0.001),
        ],
    ),
    IceSpotData(
        id: 'ice_2',
        points: [
        LatLng(center.latitude - 0.001, center.longitude + 0.001),
        LatLng(center.latitude - 0.001, center.longitude + 0.002),
        ],
    ),
    IceSpotData(
        id: 'ice_3',
        points: [
        LatLng(center.latitude + 0.001, center.longitude + 0.001),
        LatLng(center.latitude + 0.002, center.longitude + 0.002),
        ],
    ),
    ];
}
}

