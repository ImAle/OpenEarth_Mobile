import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/rent_creation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PaypalService {
  final String baseUrl = environment.rootUrl + "/paypal";
  final AuthService _authService = AuthService();

  Future<dynamic> createPayment(double amount, String currency, String description) async {
    final url = Uri.parse(baseUrl + '/createPayment');
    final token = _authService.retrieveToken();

    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    final body = {
      'currency': currency,
      'amount': amount,
      'description': description
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> capturePayment(String orderId) async {
    final url = Uri.parse(baseUrl + '/capturePayment');
    final token = _authService.retrieveToken();

    // Get the stored rent data
    final prefs = await SharedPreferences.getInstance();
    final rentJson = prefs.getString('rent');

    // Parse the JSON string back into a RentCreation object
    final RentCreation? rent = rentJson != null
        ? RentCreation.fromJson(jsonDecode(rentJson))
        : null;

    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    final queryParams = {'orderId': orderId};

    final body = {
      'houseId': rent?.houseId,
      'startTime': rent?.startTime,
      'endTime': rent?.endTime,
    };

    final response = await http.post(
      Uri.parse('$url').replace(queryParameters: queryParams),
      headers: headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }
}