import 'dart:convert';
import 'package:contoh_modul6/config/api_config.dart';
import 'package:contoh_modul6/models/booking_model.dart';
import 'package:contoh_modul6/services/auth_service.dart';

class BookingService {
  static String get _base => '${ApiConfig.baseUrl}/api/bookings';

  // =========================
  // GET MY BOOKINGS
  // =========================
  static Future<List<BookingModel>> getMyBookings() async {
    final url = Uri.parse(_base);

    final response = await AuthService.authenticatedRequest(
      method: 'GET',
      url: url,
    );

    final body = json.decode(response.body);

    print('GET BOOKINGS RESPONSE:');
    print(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];

      List<dynamic> list = [];

      // fleksibel sesuai bentuk API
      if (data is Map && data['bookings'] != null) {
        list = data['bookings'];
      } else if (data is List) {
        list = data;
      }

      return list.map((e) {
        print('BOOKING ITEM: $e');
        return BookingModel.fromJson(e);
      }).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data pemesanan');
    }
  }

  // =========================
  // GET ALL BOOKINGS
  // =========================
  static Future<List<BookingModel>> getAllBookings() async {
    final url = Uri.parse(_base);

    final response = await AuthService.authenticatedRequest(
      method: 'GET',
      url: url,
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];

      List<dynamic> list = [];

      if (data is Map && data['bookings'] != null) {
        list = data['bookings'];
      } else if (data is List) {
        list = data;
      }

      return list.map((e) => BookingModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil semua pemesanan');
    }
  }

  // =========================
  // CREATE BOOKING
  // =========================
  static Future<BookingModel> createBooking({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    String pickupLocation = 'Kantor Pusat',
    String returnLocation = 'Kantor Pusat',
  }) async {
    String fmtDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final url = Uri.parse(_base);

    final response = await AuthService.authenticatedRequest(
      method: 'POST',
      url: url,
      body: {
        'car': carId,
        'startDate': fmtDate(startDate),
        'endDate': fmtDate(endDate),
        'pickupLocation': pickupLocation,
        'returnLocation': returnLocation,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    final body = json.decode(response.body);

    print('CREATE BOOKING RESPONSE:');
    print(response.body);

    if (response.statusCode == 201) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat pemesanan');
    }
  }

  // =========================
  // CONFIRM BOOKING
  // =========================
  static Future<BookingModel> confirmBooking(String bookingId) async {
    final url = Uri.parse('$_base/$bookingId/confirm');

    final response = await AuthService.authenticatedRequest(
      method: 'PUT',
      url: url,
      body: {},
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal mengkonfirmasi pemesanan');
    }
  }

  // =========================
  // CANCEL BOOKING
  // =========================
  static Future<BookingModel> cancelBooking(String bookingId) async {
    final url = Uri.parse('$_base/$bookingId/cancel');

    final response = await AuthService.authenticatedRequest(
      method: 'PUT',
      url: url,
      body: {},
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membatalkan pemesanan');
    }
  }

  // =========================
  // GET BOOKING BY ID
  // =========================
  static Future<BookingModel> getBookingById(String bookingId) async {
    final url = Uri.parse('$_base/$bookingId');

    print('GET BOOKING BY ID: $bookingId');

    final response = await AuthService.authenticatedRequest(
      method: 'GET',
      url: url,
    );

    print('DETAIL BOOKING RESPONSE:');
    print(response.body);

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Pemesanan tidak ditemukan');
    }
  }
}