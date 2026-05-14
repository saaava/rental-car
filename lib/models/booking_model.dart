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
  final String? pickupLocation;
  final String? returnLocation;
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
    this.pickupLocation,
    this.returnLocation,
    this.createdAt,
    this.car,
    this.user,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Resolve carId
    String? carId;
    final rawCar = json['car'];
    if (rawCar is String) {
      carId = rawCar;
    } else if (rawCar is Map) {
      carId = rawCar['_id'] as String? ?? rawCar['id'] as String?;
    }

    // Resolve userId
    String? userId;
    final rawUser = json['user'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map) {
      userId = rawUser['_id'] as String? ?? rawUser['id'] as String?;
    }

    // totalDays: coba semua kemungkinan field nama
    int totalDays = 0;
    final rawDays = json['totalDays'] ?? json['duration'] ?? json['days'];
    if (rawDays != null) {
      totalDays = (rawDays as num).toInt();
    } else {
      // Hitung manual dari tanggal jika field tidak ada
      try {
        final start = DateTime.parse(json['startDate'].toString());
        final end = DateTime.parse(json['endDate'].toString());
        totalDays = end.difference(start).inDays;
        if (totalDays < 1) totalDays = 1;
      } catch (_) {
        totalDays = 1;
      }
    }

    // totalPrice: coba semua kemungkinan field nama
    double totalPrice = 0.0;
    final rawPrice = json['totalPrice'] ?? json['totalAmount'] ?? json['amount'] ?? json['price'];
    if (rawPrice != null) {
      totalPrice = (rawPrice as num).toDouble();
    }

    return BookingModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      carId: carId,
      userId: userId,
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: DateTime.parse(json['endDate'].toString()),
      totalDays: totalDays,
      totalPrice: totalPrice,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      returnLocation: json['returnLocation'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      car: rawCar is Map ? Map<String, dynamic>.from(rawCar) : null,
      user: rawUser is Map ? Map<String, dynamic>.from(rawUser) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car': carId,
      'startDate':
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'endDate':
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      if (notes != null) 'notes': notes,
      if (pickupLocation != null) 'pickupLocation': pickupLocation,
      if (returnLocation != null) 'returnLocation': returnLocation,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get carName {
    if (car != null) {
      final brand = car!['brand'] as String? ?? '';
      final name = car!['name'] as String? ?? car!['model'] as String? ?? '';
      return '$brand $name'.trim();
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