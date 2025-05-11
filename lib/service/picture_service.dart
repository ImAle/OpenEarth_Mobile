import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuration/environment.dart';
import 'auth_service.dart';

class PictureService {
  final String baseUrl = environment.rootUrl + "/pictures";
  final AuthService authService = AuthService();

  Future<dynamic> delete(int id) async {
    final uri = Uri.parse('$baseUrl/delete').replace(
      queryParameters: {'id': id.toString()},
    );

    final token = await authService.retrieveToken();

    final response = await http.delete(
      uri,
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete picture');
    }
  }
}