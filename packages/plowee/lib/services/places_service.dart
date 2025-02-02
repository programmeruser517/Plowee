import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  final String _apiKey;

  PlacesService(this._apiKey);

  Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.parse('$_baseUrl?input=$input&types=address&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        return (json['predictions'] as List)
            .map((p) => PlacePrediction(
                  p['place_id'] as String,
                  p['description'] as String,
                ))
            .toList();
      }
    }
    return [];
  }
}

class PlacePrediction {
  final String placeId;
  final String description;

  PlacePrediction(this.placeId, this.description);
}
