import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/review_creation.dart';
import 'auth_service.dart';

class ReviewService {
  final String baseUrl = environment.rootUrl + "/review";
  final AuthService _authService = AuthService();

  // POST /api/review/create
  Future<dynamic> create(ReviewCreation review) async {
    try {
      final url = Uri.parse(baseUrl + "/create");
      final token = _authService.retrieveToken();

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };

      final reviewJson = {
        'houseId': review.houseId,
        'comment': review.comment
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(reviewJson),
      );

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // GET /api/review/house
  Future<dynamic> getFromHouseId(String houseId) async {
    final url = Uri.parse(baseUrl + "/house");
    final queryParams = {'id': houseId};

    final response = await http.get(
        Uri.parse('$url').replace(queryParameters: queryParams)
    );

    return jsonDecode(response.body);
  }
}