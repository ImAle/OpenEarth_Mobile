import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/user_creation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = environment.rootUrl + "/auth";
  final String key = 'token';

  // POST /api/auth/login
  Future<dynamic> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/login').replace(
      queryParameters: {
        'email': email,
        'password': password,
      },
    );

    final response = await http.post(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout(BuildContext context) async {
    await removeToken();
    Navigator.pushNamed(context, '/login');
  }

  // POST /api/auth/register
  Future<dynamic> register(UserCreation user) async {
    final uri = Uri.parse('$baseUrl/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  // GET /api/auth/role
  Future<dynamic> getMyRole() async {
    try {
      final uri = Uri.parse('$baseUrl/role');
      final token = await retrieveToken();

      final response = await http.get(
        uri,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get role');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<dynamic> validateResetToken(String token) async {
    try {
      final uri = Uri.parse('$baseUrl/validateToken');

      final response = await http.post(
        uri,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Invalid or expired token');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<dynamic> requestPasswordReset(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/requestReset').replace(
        queryParameters: {'email': email},
      );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request password reset');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<dynamic> resetPassword(String token, String newPassword) async {
    try {
      final uri = Uri.parse('$baseUrl/resetPassword').replace(
        queryParameters: {'newPassword': newPassword},
      );

      final response = await http.post(
        uri,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to reset password');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, token);
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
  }

  Future<void> saveMyId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("id", id);
  }

  Future<void> saveMyRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("role", role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(key);
    return token != null ? 'Bearer $token' : null;
  }

  Future<int?> getMyId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    return id;
  }

  Future<String?> getMyUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<String> retrieveToken() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('You are not logged in');
    }
    return token;
  }

}