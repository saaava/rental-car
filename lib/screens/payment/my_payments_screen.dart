import 'package:flutter/material.dart';
import 'package:contoh_modul6/models/payment_model.dart';
import 'package:contoh_modul6/services/payment_service.dart';
import 'package:intl/intl.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  List<PaymentModel> _payments = [];
  bool _isLoading = true;
  String _error = '';

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final payments = await PaymentService.getMyPayments();
      if (mounted) setState(() => _payments = payments);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'verified': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.schedule;
      case 'verified': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
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
                    ElevatedButton(onPressed: _fetchPayments, child: const Text('Coba Lagi')),
                  ]),
                )
              : _payments.isEmpty
                  ? const Center(child: Text('Belum ada riwayat pembayaran'))
                  : RefreshIndicator(
                      onRefresh: _fetchPayments,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _payments.length,
                        itemBuilder: (ctx, i) {
                          final p = _payments[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _currency.format(p.amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(p.status).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_statusIcon(p.status),
                                                size: 13, color: _statusColor(p.status)),
                                            const SizedBox(width: 4),
                                            Text(p.statusLabel,
                                                style: TextStyle(
                                                    fontSize: 12, color: _statusColor(p.status),
                                                    fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(p.methodLabel, style: TextStyle(color: Colors.grey[700])),
                                  ]),
                                  if (p.createdAt != null) ...[
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Text(_dateFormat.format(p.createdAt!),
                                          style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                                    ]),
                                  ],
                                  if (p.notes != null && p.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Icon(Icons.note, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(p.notes!,
                                            style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                                      ),
                                    ]),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
