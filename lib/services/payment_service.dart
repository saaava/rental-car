import 'dart:convert';
import 'package:contoh_modul6/config/api_config.dart';
import 'package:contoh_modul6/models/payment_model.dart';
import 'package:contoh_modul6/services/auth_service.dart';

class PaymentService {
  static String get _base => '${ApiConfig.baseUrl}/api/payments';

  static Future<PaymentModel> createPayment({
    required String bookingId,
    required String method,
    String? notes,
  }) async {

    // cek booking dulu
    final bookingUrl = Uri.parse('${ApiConfig.baseUrl}/api/bookings/$bookingId');

    print('GET BOOKING BY ID: $bookingId');

    final bookingResponse = await AuthService.authenticatedRequest(
      method: 'GET',
      url: bookingUrl,
    );

    print('DETAIL BOOKING RESPONSE: ${bookingResponse.body}');

    final bookingBody = json.decode(bookingResponse.body);

    if (bookingResponse.statusCode != 200) {
      throw Exception(
        bookingBody['message'] ?? 'Pemesanan tidak ditemukan',
      );
    }

    print('BOOKING DITEMUKAN: $bookingId');

    final url = Uri.parse(_base);

    final payload = {
      'bookingId': bookingId,
      'method': method,
      'bankName': 'BCA',
      'accountNumber': '1234567890',
      'accountName': 'Noura',
      'transactionId': 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    print('PAYMENT PAYLOAD: $payload');

    final response = await AuthService.authenticatedRequest(
      method: 'POST',
      url: url,
      body: payload,
    );

    print('PAYMENT RESPONSE: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat pembayaran');
    }
  }
}