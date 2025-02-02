import 'dart:convert';
import 'dart:js_util' as js_util;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:js_interop';

class PlacesService {
  final String _apiKey;

  PlacesService(this._apiKey);

  Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty) return [];

    try {
      // Get Google object safely
      final google = js_util.getProperty(js_util.globalThis, 'google');
      if (google == null) {
        print('Google Maps not loaded');
        return [];
      }

      final autocompleteService = js_util.callConstructor(
        js_util.getProperty(
            js_util.getProperty(js_util.getProperty(google, 'maps'), 'places'),
            'AutocompleteService'),
        [],
      );

      final request = js_util.jsify({
        'input': input,
        'componentRestrictions': {'country': 'us'}
      });

      final predictions = await js_util.promiseToFuture(js_util
          .callMethod(autocompleteService, 'getPlacePredictions', [request]));

      if (predictions != null) {
        final predictionsList = js_util
            .dartify(js_util.getProperty(predictions, 'predictions')) as List;

        final List<PlacePrediction> placeResults = [];
        for (final p in predictionsList) {
          placeResults.add(PlacePrediction(
            p['place_id'],
            p['description'],
          ));
        }
        return placeResults;
      }
    } catch (e, stackTrace) {
      print('Error fetching predictions: $e');
      print('Stack trace: $stackTrace');
    }
    return [];
  }

Future<LatLng?> getCoordinatesFromAddress(String address) async {
if (address.isEmpty) return null;

try {
    // Get Google object safely
    final google = js_util.getProperty(js_util.globalThis, 'google');
    if (google == null) {
    print('Google Maps not loaded');
    return null;
    }

    // Create Geocoder instance
    final geocoder = js_util.callConstructor(
    js_util.getProperty(js_util.getProperty(google, 'maps'), 'Geocoder'),
    [],
    );

    // Create request object
    final request = js_util.jsify({'address': address});

    // Get geocoding results
    final response = await js_util
        .promiseToFuture(js_util.callMethod(geocoder, 'geocode', [request]));

    // The response contains a 'results' property which is an array
    final results = js_util.getProperty(response, 'results');
    
    if (results != null) {
    // Get the first result
    final firstResult = js_util.getProperty(results, '0');
    if (firstResult != null) {
        // Access the geometry object
        final geometry = js_util.getProperty(firstResult, 'geometry');
        if (geometry != null) {
        // Access the location object
        final location = js_util.getProperty(geometry, 'location');
        if (location != null) {
            // Get lat and lng using the location methods
            final lat = js_util.callMethod(location, 'lat', []);
            final lng = js_util.callMethod(location, 'lng', []);
            
            if (lat != null && lng != null) {
            return LatLng(
                double.parse(lat.toString()),
                double.parse(lng.toString()),
            );
            }
        }
        }
    }
    }
    
    print('No results found for address: $address');
    return null;
} catch (e, stackTrace) {
    print('Error geocoding address: $e');
    print('Stack trace: $stackTrace');
    return null;
}
}
}

class PlacePrediction {
  final String placeId;
  final String description;

  PlacePrediction(this.placeId, this.description);
}
