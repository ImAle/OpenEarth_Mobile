import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/report_creation.dart';
import 'auth_service.dart';

class ReportService {
  final String baseUrl = environment.rootUrl + "/report";
  final AuthService _authService = AuthService();

  // POST /api/report/create
  Future<dynamic> create(ReportCreation report) async {
    try {
      final url = Uri.parse(baseUrl + '/create');
      final token = _authService.retrieveToken();

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json'
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(report.toJson()),
      );

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // GET /api/report
  Future<dynamic> getAll() async {
    try {
      final url = Uri.parse(baseUrl);
      final token = _authService.retrieveToken();

      final headers = {
        'Authorization': token,
      };

      final response = await http.get(url, headers: headers);
      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // GET /api/report/get
  Future<dynamic> getById(String id) async {
    try {
      final url = Uri.parse(baseUrl + '/get');
      final token = _authService.retrieveToken();

      final headers = {
        'Authorization': token
      };

      final queryParams = {'id': id};

      final response = await http.get(
          Uri.parse('$url').replace(queryParameters: queryParams),
          headers: headers
      );

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // DELETE /api/report/delete
  Future<dynamic> delete(int id) async {
    try {
      final url = Uri.parse(baseUrl + '/delete');
      final token = _authService.retrieveToken();

      final headers = {
        'Authorization': token
      };

      final queryParams = {'id': id.toString()};

      final response = await http.delete(
          Uri.parse('$url').replace(queryParameters: queryParams),
          headers: headers
      );

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }
}