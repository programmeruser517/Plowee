import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/map_screen.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> reportIceSpot({
    required LatLng location,
    required String intersection1,
    required String intersection2,
  }) async {
    try {
      await supabase.from('report-audit').insert({
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'intersection1': intersection1,
        'intersection2': intersection2,
        'timestamp': DateTime.now().toIso8601String(),
        'request_count': 1,
      });

      // turn the danger button green, method in map_screen.dart
      //_setDangerButtonColor(Colors.green);
    } catch (e) {
      throw Exception('Failed to report ice spot: $e');
    }
  }
}
