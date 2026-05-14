import 'package:flutter/material.dart';
import 'dart:async';
import 'package:contoh_modul6/models/car_model.dart';
import 'package:contoh_modul6/services/car_service.dart';
import 'package:contoh_modul6/widgets/car_card.dart';
import 'package:contoh_modul6/widgets/loading_indicator.dart';
import 'package:contoh_modul6/screens/car/car_form_screen.dart';
import 'package:contoh_modul6/services/auth_service.dart';
import 'package:contoh_modul6/screens/auth/login_screen.dart';
import 'package:contoh_modul6/screens/booking/booking_form_screen.dart';
import 'package:contoh_modul6/screens/booking/my_bookings_screen.dart';
import 'package:contoh_modul6/screens/payment/my_payments_screen.dart';
import 'package:contoh_modul6/screens/admin/admin_bookings_screen.dart';
import 'package:contoh_modul6/screens/admin/admin_payments_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<CarModel> _cars = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _role = 'user';
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchCars();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _role = role ?? 'user');
  }

  Future<void> _fetchCars([String? searchQuery]) async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final result = await CarService.getCars(search: searchQuery);
      if (mounted) setState(() => _cars = result['cars'] as List<CarModel>);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCar(CarModel car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mobil'),
        content: Text('Hapus ${car.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CarService.deleteCar(car.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mobil berhasil dihapus'), backgroundColor: Colors.green));
          _fetchCars();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.directions_car, color: Colors.orange),
          const SizedBox(width: 8),
          Text('Car Rental ${_role == 'admin' ? '(Admin)' : ''}'),
        ]),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.book_online),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
              tooltip: 'Kelola Booking',
            ),
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdminPaymentsScreen())),
              tooltip: 'Verifikasi Pembayaran',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
              tooltip: 'Pemesanan Saya',
            ),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyPaymentsScreen())),
              tooltip: 'Pembayaran Saya',
            ),
          ],
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Logout'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari mobil',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchController.clear());
                          _fetchCars();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () => _fetchCars(value));
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Memuat data mobil...')
                : _errorMessage.isNotEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: () => _fetchCars(_searchController.text), child: const Text('Coba Lagi')),
                      ]))
                    : _cars.isEmpty
                        ? const Center(child: Text('Tidak ada data mobil'))
                        : RefreshIndicator(
                            onRefresh: () => _fetchCars(_searchController.text),
                            child: ListView.builder(
                              itemCount: _cars.length,
                              itemBuilder: (context, index) {
                                final car = _cars[index];
                                return CarCard(
                                  car: car,
                                  onBook: !isAdmin ? () async {
                                    final res = await Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => BookingFormScreen(car: car)));
                                    if (res == true) _fetchCars(_searchController.text);
                                  } : null,
                                  onEdit: isAdmin ? () async {
                                    final result = await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => CarFormScreen(car: car)));
                                    if (result == true) _fetchCars(_searchController.text);
                                  } : null,
                                  onDelete: isAdmin ? () => _deleteCar(car) : null,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CarFormScreen()));
          if (result == true) _fetchCars(_searchController.text);
        },
        backgroundColor: const Color(0xFF1A1A2E),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}
