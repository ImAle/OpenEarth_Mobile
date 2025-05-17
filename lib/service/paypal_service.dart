import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/payment_creation.dart';
import 'package:openearth_mobile/model/rent_creation.dart';
import 'package:openearth_mobile/screen/paypal_webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PaypalService {
  final String baseUrl = "${environment.rootUrl}/paypal";
  final AuthService _authService = AuthService();

  Future<void> initiatePaypalPayment(
      BuildContext context,
      double amount,
      String currency,
      String description,
      RentCreation rentData,
      Function(String) onSuccess,
      Function() onCancel,
      ) async {
    try {
      // Store reservation data
      await _storeRentData(rentData);

      final paymentResponse = await createPayment(amount, currency, description);
      final approvalUrl = paymentResponse['message'];

      if (approvalUrl == null) {
        throw Exception('No approval link received');
      }

      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaypalWebViewScreen(
            approvalUrl: approvalUrl,
            onPaymentSuccess: (String orderId) async {
              final captureResponse = await capturePayment(orderId);
              Navigator.of(context).pop(captureResponse);
              onSuccess(orderId);
            },
            onPaymentCancelled: () {
              Navigator.of(context).pop();
              onCancel();
            },
          ),
        ),
      );

      return result;
    } catch (e) {
      onCancel();
      rethrow;
    }
  }

  Future<void> _storeRentData(RentCreation rentData) async {
    final prefs = await SharedPreferences.getInstance();
    final rentJson = jsonEncode(rentData.toJson());
    await prefs.setString('rent', rentJson);
  }


  Future<dynamic> createPayment(double amount, String currency, String description) async {
    final url = Uri.parse('$baseUrl/createPayment');
    final token = await _authService.retrieveToken();

    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    final body = PaymentCreation(currency: currency, description: description, amount: amount);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<dynamic> capturePayment(String orderId) async {
    final url = Uri.parse('$baseUrl/capturePayment');
    final token = await _authService.retrieveToken();

    // Get booked home data
    final prefs = await SharedPreferences.getInstance();
    final rentJson = prefs.getString('rent');

    final RentCreation? rent = rentJson != null
        ? RentCreation.fromJson(jsonDecode(rentJson))
        : null;

    if (rent == null) {
      throw Exception('No rent data found');
    }

    final headers = {
      'Authorization': token,
      'Content-Type': 'application/json'
    };

    final queryParams = {'orderId': orderId};

    final body = RentCreation(startTime: rent.startTime, endTime: rent.endTime, houseId: rent.houseId);

    final response = await http.post(url.replace(queryParameters: queryParams), headers: headers, body: jsonEncode(body));

    if (response.statusCode != 201) {
      throw Exception('Error at payment: ${response.body}');
    }

    await prefs.remove('rent');

    return jsonDecode(response.body);
  }
}