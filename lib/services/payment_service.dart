import 'dart:convert';
import 'package:contoh_modul6/config/api_config.dart';
import 'package:contoh_modul6/models/payment_model.dart';
import 'package:contoh_modul6/services/auth_service.dart';

class PaymentService {
  static String get _base => '${ApiConfig.baseUrl}/api/payments';

  static Future<PaymentModel> createPayment({
    required String bookingId,
    required String method,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? notes,
  }) async {
    final url = Uri.parse(_base);

    final payload = <String, dynamic>{
      'bookingId': bookingId,
      'method': method,
    };

    if (method == 'transfer_bank') {
      payload['bankName'] = bankName ?? 'BCA';
      payload['accountNumber'] = accountNumber ?? '';
      payload['accountName'] = accountName ?? '';
      payload['transactionId'] = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    }

    if (notes != null && notes.isNotEmpty) {
      payload['notes'] = notes;
    }

    print('[PaymentService] createPayment payload: $payload');

    final response = await AuthService.authenticatedRequest(
      method: 'POST',
      url: url,
      body: payload,
    );

    print('[PaymentService] createPayment status: ${response.statusCode}');
    print('[PaymentService] createPayment body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = body['data'];
      if (data == null) throw Exception('Respons API tidak valid');
      final paymentJson = data['payment'] ?? data;
      return PaymentModel.fromJson(paymentJson);
    } else {
      throw Exception(body['message'] ?? body['error'] ?? 'Gagal membuat pembayaran');
    }
  }

  static Future<List<PaymentModel>> getMyPayments() async {
    final url = Uri.parse(_base);

    final response = await AuthService.authenticatedRequest(
      method: 'GET',
      url: url,
    );

    print('[PaymentService] getMyPayments status: ${response.statusCode}');
    print('[PaymentService] getMyPayments body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      List<dynamic> list = [];
      if (data is Map) {
        list = data['payments'] ?? data['data'] ?? [];
      } else if (data is List) {
        list = data;
      }
      return list.map((e) => PaymentModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil riwayat pembayaran');
    }
  }

  static Future<List<PaymentModel>> getAllPayments() async {
    final url = Uri.parse(_base);

    final response = await AuthService.authenticatedRequest(
      method: 'GET',
      url: url,
    );

    print('[PaymentService] getAllPayments status: ${response.statusCode}');
    print('[PaymentService] getAllPayments body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      List<dynamic> list = [];
      if (data is Map) {
        list = data['payments'] ?? data['data'] ?? [];
      } else if (data is List) {
        list = data;
      }
      return list.map((e) => PaymentModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil semua pembayaran');
    }
  }

  static Future<PaymentModel> getPaymentById(String paymentId) async {
    final url = Uri.parse('$_base/$paymentId');

    final response = await AuthService.authenticatedRequest(
      method: 'GET',
      url: url,
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final paymentJson = data['payment'] ?? data;
      return PaymentModel.fromJson(paymentJson);
    } else {
      throw Exception(body['message'] ?? 'Pembayaran tidak ditemukan');
    }
  }

  static Future<PaymentModel> verifyPayment(
    String paymentId, {
    String status = 'success',
    String? notes,
  }) async {
    assert(status == 'success' || status == 'failed',
        'status harus "success" atau "failed"');

    final url = Uri.parse('$_base/$paymentId/verify');

    final payload = <String, dynamic>{
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    print('[PaymentService] verifyPayment payload: $payload');

    final response = await AuthService.authenticatedRequest(
      method: 'PUT',
      url: url,
      body: payload,
    );

    print('[PaymentService] verifyPayment status: ${response.statusCode}');
    print('[PaymentService] verifyPayment body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final paymentJson = data['payment'] ?? data;
      return PaymentModel.fromJson(paymentJson);
    } else {
      throw Exception(body['message'] ?? 'Gagal memverifikasi pembayaran');
    }
  }

  static Future<PaymentModel> rejectPayment(
    String paymentId, {
    String? reason,
  }) async {
    return verifyPayment(paymentId, status: 'failed', notes: reason);
  }

  static Future<PaymentModel> refundPayment(
    String paymentId, {
    String? reason,
  }) async {
    final url = Uri.parse('$_base/$paymentId/refund');

    final payload = <String, dynamic>{
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };

    final response = await AuthService.authenticatedRequest(
      method: 'PUT',
      url: url,
      body: payload,
    );

    print('[PaymentService] refundPayment status: ${response.statusCode}');
    print('[PaymentService] refundPayment body: ${response.body}');

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final paymentJson = data['payment'] ?? data;
      return PaymentModel.fromJson(paymentJson);
    } else {
      throw Exception(body['message'] ?? 'Gagal memproses refund');
    }
  }
}