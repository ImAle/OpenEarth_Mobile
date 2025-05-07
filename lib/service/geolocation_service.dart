import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/environment.dart';

class GeolocationService {
  final String baseUrl = environment.rootUrl + "/geo";

  Future<dynamic> getLocationByCoords(double lat, double lng) async {
    final uri = Uri.parse('$baseUrl/reverse').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get location by coordinates');
    }
  }

  Future<dynamic> getCoords(String location) async {
    final uri = Uri.parse('$baseUrl/search').replace(
      queryParameters: {'location': location},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get coordinates');
    }
  }

}