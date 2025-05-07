import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'auth_service.dart';

class UserService {
  final String baseUrl = environment.rootUrl + "/user";
  final AuthService _authService = AuthService();
  final NavigatorState navigator;

  UserService({required this.navigator});

  // GET /api/user
  Future<dynamic> getAllUsers() async {
    try {
      final url = Uri.parse(baseUrl);
      final token = _authService.retrieveToken();

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

  // GET /api/user/profile
  Future<dynamic> getProfile() async {
    final url = Uri.parse(baseUrl + '/profile');
    final token = _authService.retrieveToken();

    final headers = {
      'Authorization': token
    };

    final response = await http.get(url, headers: headers);
    return jsonDecode(response.body);
  }

  // GET /api/user/details
  Future<dynamic> getUser(int id) async {
    final url = Uri.parse(baseUrl + '/details');
    final queryParams = {'id': id.toString()};

    final response = await http.get(
        Uri.parse('$url').replace(queryParameters: queryParams)
    );

    return jsonDecode(response.body);
  }

  // PUT /api/user/picture
  Future<dynamic> update(File picture) async {
    try {
      final url = Uri.parse(baseUrl + '/picture');
      final token = _authService.retrieveToken();

      var request = http.MultipartRequest('PUT', url);

      request.headers.addAll({
        'Authorization': token,
      });

      request.files.add(
          await http.MultipartFile.fromPath('picture', picture.path)
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (error) {
      print(error);
      throw error;
    }
  }

}