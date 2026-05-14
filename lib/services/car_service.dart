import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:contoh_modul6/config/api_config.dart';
import 'package:contoh_modul6/models/car_model.dart';
import 'package:contoh_modul6/services/auth_service.dart';

class CarService {
  static Future<Map<String, dynamic>> getCars({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    String? brand,
    String? transmission,
    String? fuel,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
    if (transmission != null && transmission.isNotEmpty) {
      queryParams['transmission'] = transmission;
    }
    if (fuel != null && fuel.isNotEmpty) queryParams['fuel'] = fuel;

    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carsPrefix}')
        .replace(queryParameters: queryParams);

    final response = await http.get(url);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final List<dynamic> carsJson = data['cars'] ?? [];
      final cars = carsJson.map((json) => CarModel.fromJson(json)).toList();
      // final pagination = data['pagination'];

      return {
        'cars': cars,
        // 'pagination': pagination,
      };
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data mobil');
    }
  }

  /// Ambil detail satu mobil berdasarkan ID
  static Future<CarModel> getCarById(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$id');

    final response = await http.get(url);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return CarModel.fromJson(body['data']['car']);
    } else {
      throw Exception(body['message'] ?? 'Mobil tidak ditemukan');
    }
  }

  static Future<CarModel> createCar(CarModel car) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carsPrefix}');

    final response = await AuthService.authenticatedRequest(
      method: 'POST',
      url: url,
      body: car.toJson(),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      return CarModel.fromJson(body['data']['car']);
    }  
    else {
      throw Exception(body['message'] ?? 'Gagal menambahkan mobil');
    }
  }

  /// Update data mobil (Admin only)
  static Future<CarModel> updateCar(String id, CarModel car) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$id');

    final response = await AuthService.authenticatedRequest(
      method: 'PUT',
      url: url,
      body: car.toJson(),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return CarModel.fromJson(body['data']['car']);
    } else {
      throw Exception(body['message'] ?? 'Gagal memperbarui data mobil');
    }
  }

  /// Hapus mobil (Admin only)
  static Future<void> deleteCar(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.carsPrefix}/$id');

    final response = await AuthService.authenticatedRequest(
      method: 'DELETE',
      url: url,
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal menghapus mobil');
    }
  }
}

