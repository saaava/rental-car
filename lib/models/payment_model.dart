class PaymentModel {
  final String? id;
  final String? bookingId;
  final String? userId;
  final double amount;
  final String method;
  final String status;
  final String? proofImageUrl;
  final String? notes;
  final DateTime? createdAt;
  final Map<String, dynamic>? booking;

  PaymentModel({
    this.id,
    this.bookingId,
    this.userId,
    required this.amount,
    required this.method,
    this.status = 'pending',
    this.proofImageUrl,
    this.notes,
    this.createdAt,
    this.booking,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    String? bookingId;
    final rawBooking = json['booking'] ?? json['bookingId'];
    if (rawBooking is String) {
      bookingId = rawBooking;
    } else if (rawBooking is Map) {
      bookingId = rawBooking['_id'] as String? ?? rawBooking['id'] as String?;
    }

    String? userId;
    final rawUser = json['user'] ?? json['userId'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map) {
      userId = rawUser['_id'] as String? ?? rawUser['id'] as String?;
    }

    final method = json['method'] as String?
        ?? json['paymentMethod'] as String?
        ?? 'transfer_bank';

    return PaymentModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      bookingId: bookingId,
      userId: userId,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: method,
      status: json['status'] as String? ?? 'pending',
      proofImageUrl: json['proofImage'] as String?
          ?? json['proofImageUrl'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      booking: rawBooking is Map
          ? Map<String, dynamic>.from(rawBooking)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': bookingId,
      'amount': amount,
      'method': method,
      if (proofImageUrl != null) 'proofImage': proofImageUrl,
      if (notes != null) 'notes': notes,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'success':
      case 'verified':
        return 'Terverifikasi';
      case 'failed':
      case 'rejected':
      case 'refunded':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String get methodLabel {
    switch (method) {
      case 'transfer_bank':
        return 'Transfer Bank';
      case 'transfer':
        return 'Transfer Bank';
      case 'cash':
        return 'Tunai';
      case 'credit_card':
        return 'Kartu Kredit';
      case 'e-wallet':
      case 'ewallet':
        return 'E-Wallet';
      default:
        return method;
    }
  }
}