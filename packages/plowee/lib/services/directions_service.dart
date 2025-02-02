import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
final String apiKey;

DirectionsService(this.apiKey);

Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/directions/json'
    '?origin=${origin.latitude},${origin.longitude}'
    '&destination=${destination.latitude},${destination.longitude}'
    '&mode=driving'
    '&key=$apiKey'
    );

    try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
        return _decodePolyline(
            data['routes'][0]['overview_polyline']['points']
        );
        } else {
        throw Exception('Directions API error: ${data['status']}');
        }
    } else {
        throw Exception('Failed to fetch directions');
    }
    } catch (e) {
    throw Exception('Error getting directions: $e');
    }
}

List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
    int b;
    int shift = 0;
    int result = 0;
    do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
}
}

