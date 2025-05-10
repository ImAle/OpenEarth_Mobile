import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/service/auth_service.dart';

class HouseService {
  final String baseUrl = environment.rootUrl + "/house";

  // Stream controllers for filtered data
  final ValueNotifier<List<HousePreview>?> _filteredHousesNotifier = ValueNotifier<List<HousePreview>?>(null);
  ValueNotifier<List<HousePreview>?> get filteredHouses => _filteredHousesNotifier;

  void updateFilteredHouses(List<HousePreview>? houses) {
    _filteredHousesNotifier.value = houses;
  }

  // GET /api/house
  Future<dynamic> getAll({String? location, double? minPrice, double? maxPrice,
    int? beds, int? guests, String? category, String? currency,}) async {

    Map<String, String> queryParams = {};

    if (location != null && location.isNotEmpty) queryParams['location'] = location;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (beds != null && beds > 0) queryParams['beds'] = beds.toString();
    if (guests != null && guests > 0) queryParams['guests'] = guests.toString();
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (currency != null && currency.isNotEmpty) queryParams['currency'] = currency;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data['houses'] != null) {
        final List<HousePreview> houses = (data['houses'] as List)
            .map((house) => HousePreview.fromJson(house))
            .toList();

        updateFilteredHouses(houses);
      }else{
        updateFilteredHouses([]);
      }

      return data;

    } else {
      throw Exception('Failed to load houses');
    }
  }

  Future<dynamic> getHousesNearTo(int id, int km, String currency) async {
    final queryParams = {
      'id': id.toString(),
      'km': km.toString(),
      'currency': currency,
    };

    final uri = Uri.parse('$baseUrl/nearTo').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load houses near to');
    }
  }

  Future<dynamic> getHousesByOwner(int id, String currency) async {
    final queryParams = {
      'owner': id.toString(),
      'currency': currency,
    };

    final uri = Uri.parse('$baseUrl/owner').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load houses by owner');
    }
  }

  // GET /api/house/details
  Future<dynamic> getById(int id, String currency) async {
    final queryParams = {
      'id': id.toString(),
      'currency': currency,
    };

    final uri = Uri.parse('$baseUrl/details').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load house details');
    }
  }

  // GET /api/house/categories
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic>? categories = data['categories'];
      if (categories == null) {
        throw Exception('Categories key not found or null');
      }

      return categories.map((category) => category.toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // GET /api/house/status
  Future<List<String>> getStatuses() async {
    final uri = Uri.parse('$baseUrl/status');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((status) => status.toString()).toList();
    } else {
      throw Exception('Failed to load statuses');
    }
  }

  // DELETE /api/house/delete
  Future<dynamic> delete(int id) async {
    try {
      final queryParams = {'id': id.toString()};
      final uri = Uri.parse('$baseUrl/delete').replace(queryParameters: queryParams);

      final token = AuthService().retrieveToken();

      final response = await http.delete(
        uri,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete house');
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

}