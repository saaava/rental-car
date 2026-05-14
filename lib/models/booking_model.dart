class BookingModel {
  final String? id;
  final String? carId;
  final String? userId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final Map<String, dynamic>? car;
  final Map<String, dynamic>? user;

  BookingModel({
    this.id,
    this.carId,
    this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    this.status = 'pending',
    this.notes,
    this.createdAt,
    this.car,
    this.user,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'],

      carId: json['car'] is String
          ? json['car']
          : json['car']?['_id'] ?? json['car']?['id'],

      userId: json['user'] is String
          ? json['user']
          : json['user']?['_id'] ?? json['user']?['id'],

      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),

      // FIX
      totalDays: json['totalDays']
          ?? json['duration']
          ?? 0,

      // FIX
      totalPrice: (json['totalPrice']
              ?? json['totalAmount']
              ?? 0)
          .toDouble(),

      status: json['status'] ?? 'pending',

      notes: json['notes'],

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      car: json['car'] is Map
          ? Map<String, dynamic>.from(json['car'])
          : null,

      user: json['user'] is Map
          ? Map<String, dynamic>.from(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car': carId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      if (notes != null) 'notes': notes,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'confirmed': return 'Dikonfirmasi';
      case 'active': return 'Aktif';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  String get carName {
    if (car != null) {
      return '${car!['brand'] ?? ''} ${car!['name'] ?? ''}'.trim();
    }
    return 'Mobil';
  }

  String get userName {
    if (user != null) return user!['name'] as String? ?? '-';
    return '-';
  }

  String get userEmail {
    if (user != null) return user!['email'] as String? ?? '-';
    return '-';
  }
}