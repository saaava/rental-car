import 'package:flutter/material.dart';
import 'package:contoh_modul6/models/booking_model.dart';
import 'package:contoh_modul6/services/booking_service.dart';
import 'package:intl/intl.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen>
    with SingleTickerProviderStateMixin {
  List<BookingModel> _all = [];
  bool _isLoading = true;
  String _error = '';
  late TabController _tabController;

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final bookings = await BookingService.getAllBookings();
      if (mounted) setState(() => _all = bookings);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<BookingModel> get _pending => _all.where((b) => b.status == 'pending').toList();
  List<BookingModel> get _confirmed => _all.where((b) => b.status == 'confirmed' || b.status == 'active').toList();
  List<BookingModel> get _others => _all.where((b) => b.status == 'completed' || b.status == 'cancelled').toList();

  Future<void> _confirmBooking(BookingModel b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pemesanan'),
        content: Text('Konfirmasi pemesanan ${b.carName} oleh ${b.userName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
            child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await BookingService.confirmBooking(b.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemesanan dikonfirmasi'), backgroundColor: Colors.green),
        );
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildList(List<BookingModel> bookings, {bool showConfirm = false}) {
    if (bookings.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) {
        final b = bookings[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.carName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(b.userName,
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(b.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(b.statusLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _Row(Icons.email, 'Email', b.userEmail),
                    _Row(Icons.calendar_today, 'Mulai', _dateFormat.format(b.startDate)),
                    _Row(Icons.event, 'Selesai', _dateFormat.format(b.endDate)),
                    _Row(Icons.schedule, 'Durasi', '${b.totalDays} hari'),
                    _Row(Icons.monetization_on, 'Total', _currency.format(b.totalPrice), bold: true),
                    if (showConfirm && b.status == 'pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmBooking(b),
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Konfirmasi Pemesanan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pemesanan'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Aktif (${_confirmed.length})'),
            Tab(text: 'Lainnya'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _fetchBookings, child: const Text('Coba Lagi')),
                ]))
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_pending, showConfirm: true),
                      _buildList(_confirmed),
                      _buildList(_others),
                    ],
                  ),
                ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool bold;
  const _Row(this.icon, this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.orange[800] : Colors.black87,
              )),
        ),
      ]),
    );
  }
}
