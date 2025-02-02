import 'dart:convert';
import 'dart:js_util' as js_util;
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
}

class PlacePrediction {
  final String placeId;
  final String description;

  PlacePrediction(this.placeId, this.description);
}
