import 'package:flutter/material.dart';
import 'package:contoh_modul6/models/booking_model.dart';
import 'package:contoh_modul6/services/booking_service.dart';
import 'package:contoh_modul6/screens/payment/payment_form_screen.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _error = '';

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final bookings = await BookingService.getMyBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pemesanan'),
        content: const Text('Yakin ingin membatalkan pemesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await BookingService.cancelBooking(booking.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemesanan dibatalkan'), backgroundColor: Colors.orange),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemesanan Saya'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _fetchBookings, child: const Text('Coba Lagi')),
                  ]),
                )
              : _bookings.isEmpty
                  ? const Center(child: Text('Belum ada pemesanan'))
                  : RefreshIndicator(
                      onRefresh: _fetchBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _bookings.length,
                        itemBuilder: (ctx, i) {
                          final b = _bookings[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A2E),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(b.carName,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                      _InfoRow(Icons.calendar_today, 'Mulai',
                                          _dateFormat.format(b.startDate)),
                                      _InfoRow(Icons.event, 'Selesai',
                                          _dateFormat.format(b.endDate)),
                                      _InfoRow(Icons.schedule, 'Durasi',
                                          '${b.totalDays} hari'),
                                      _InfoRow(Icons.monetization_on, 'Total',
                                          _currency.format(b.totalPrice),
                                          highlight: true),
                                      if (b.notes != null && b.notes!.isNotEmpty)
                                        _InfoRow(Icons.note, 'Catatan', b.notes!),
                                    ],
                                  ),
                                ),
                                if (b.status == 'pending' || b.status == 'confirmed')
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                    child: Row(
                                      children: [
                                        if (b.status == 'confirmed' || b.status == 'pending')
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                final res = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PaymentFormScreen(booking: b),
                                                  ),
                                                );
                                                if (res == true) _fetchBookings();
                                              },
                                              icon: const Icon(Icons.payment, size: 16),
                                              label: const Text('Bayar'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ),
                                        if (b.status == 'pending') ...[
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _cancelBooking(b),
                                              icon: const Icon(Icons.cancel_outlined, size: 16),
                                              label: const Text('Batalkan'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow(this.icon, this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 15, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.orange[800] : Colors.black87,
              fontSize: 13,
            ),
          ),
        ),
      ]),
    );
  }
}
