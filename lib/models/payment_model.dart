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
    return PaymentModel(
      id: json['_id'] as String?,
      bookingId: json['booking'] is String ? json['booking'] : (json['booking']?['_id'] as String?),
      userId: json['user'] is String ? json['user'] : (json['user']?['_id'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['paymentMethod'] as String? ?? json['method'] as String? ?? 'transfer',
      status: json['status'] as String? ?? 'pending',
      proofImageUrl: json['proofImage'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      booking: json['booking'] is Map ? json['booking'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': bookingId,
      'amount': amount,
      'paymentMethod': method,
      if (proofImageUrl != null) 'proofImage': proofImageUrl,
      if (notes != null) 'notes': notes,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu Verifikasi';
      case 'success':
      case 'verified': return 'Terverifikasi';
      case 'failed':
      case 'rejected': return 'Ditolak';
      default: return status;
    }
  }

  String get methodLabel {
    switch (method) {
      case 'transfer': return 'Transfer Bank';
      case 'cash': return 'Tunai';
      case 'credit_card': return 'Kartu Kredit';
      case 'e-wallet': return 'E-Wallet';
      default: return method;
    }
  }
}