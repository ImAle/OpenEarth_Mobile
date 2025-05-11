import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/rent_creation.dart';
import 'auth_service.dart';

class RentService {
  final String baseUrl = environment.rootUrl + "/rent";

  // POST /api/rent/create
  Future<dynamic> create(RentCreation rent) async {
    try {
      final url = Uri.parse(baseUrl + "/create");
      final token = await AuthService().retrieveToken();

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final response = await http.post(url, headers: headers, body: jsonEncode(rent.toJson()),);

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // GET /api/rent/myRents
  Future<dynamic> getMyRents() async {
    try {
      final url = Uri.parse(baseUrl + '/myRents');
      final token = await AuthService().retrieveToken();

      final headers = {
        'Authorization': token
      };

      final response = await http.get(url, headers: headers);
      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // GET /api/rent/house
  Future<dynamic> getRentsByHouse(int houseId) async {
    try {
      final url = Uri.parse(baseUrl + '/house');
      final queryParams = {'id': houseId.toString()};

      final response = await http.get(
          Uri.parse('$url').replace(queryParameters: queryParams)
      );

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // GET /api/rent/houses
  Future<dynamic> getRentsOfMyHouses() async {
    try {
      final url = Uri.parse(baseUrl + '/houses');
      final token = await AuthService().retrieveToken();

      final headers = {
        'Authorization': token
      };

      final response = await http.get(url, headers: headers);
      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // POST /api/rent/cancel
  Future<dynamic> cancel(int rentId) async {
    try {
      final url = Uri.parse(baseUrl + '/cancel');
      final token = await AuthService().retrieveToken();

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };

      final queryParams = {'rentId': rentId.toString()};

      final response = await http.post(
        Uri.parse('$url').replace(queryParameters: queryParams),
        headers: headers,
      );

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }
}