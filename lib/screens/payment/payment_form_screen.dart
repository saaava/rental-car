import 'package:flutter/material.dart';
import 'package:contoh_modul6/models/booking_model.dart';
import 'package:contoh_modul6/services/payment_service.dart';
import 'package:contoh_modul6/services/booking_service.dart';
import 'package:intl/intl.dart';

class PaymentFormScreen extends StatefulWidget {
  final BookingModel booking;
  const PaymentFormScreen({super.key, required this.booking});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  String _selectedMethod = 'transfer_bank';
  final _proofController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<Map<String, dynamic>> _methods = [
    {'value': 'transfer_bank', 'label': 'Transfer Bank', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'value': 'cash', 'label': 'Tunai', 'icon': Icons.money, 'color': Colors.green},
    {'value': 'e-wallet', 'label': 'E-Wallet', 'icon': Icons.phone_android, 'color': Colors.purple},
    {'value': 'credit_card', 'label': 'Kartu Kredit', 'icon': Icons.credit_card, 'color': Colors.orange},
  ];

  Future<void> _submitPayment() async {
    if (_selectedMethod == 'transfer' &&
        _proofController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan URL bukti transfer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingId = widget.booking.id;

      print('BOOKING ID YANG DIKIRIM: $bookingId');

      if (bookingId == null || bookingId.isEmpty) {
        throw Exception(
            'ID pemesanan kosong. Refresh halaman lalu coba lagi.');
      }

      // cek booking dulu
      final booking =
          await BookingService.getBookingById(bookingId);

      print('BOOKING DITEMUKAN: ${booking.id}');

      await PaymentService.createPayment(
        bookingId: bookingId,
        method: _selectedMethod == 'transfer'
            ? 'transfer_bank'
            : _selectedMethod,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      print('ERROR PAYMENT: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _proofController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Card(
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mobil', style: TextStyle(color: Colors.white70)),
                        Text(widget.booking.carName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Durasi', style: TextStyle(color: Colors.white70)),
                        Text('${widget.booking.totalDays} hari',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(color: Colors.white70)),
                        Text(_currency.format(widget.booking.totalPrice),
                            style: const TextStyle(
                                color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment method
            const Text('Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...(_methods.map((m) => _MethodTile(
                  value: m['value'] as String,
                  label: m['label'] as String,
                  icon: m['icon'] as IconData,
                  color: m['color'] as Color,
                  groupValue: _selectedMethod,
                  onChanged: (v) => setState(() => _selectedMethod = v!),
                ))),
            const SizedBox(height: 16),

            // Proof URL (for transfer)
            if (_selectedMethod == 'transfer') ...[
              const Text('URL Bukti Transfer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _proofController,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            const Text('Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Konfirmasi Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _MethodTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? const Color(0xFF1A1A2E) : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
          color: selected ? const Color(0xFF1A1A2E).withOpacity(0.05) : Colors.white,
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A1A2E),
          ),
        ]),
      ),
    );
  }
}
