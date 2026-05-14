import 'package:flutter/material.dart';
import 'package:contoh_modul6/models/payment_model.dart';
import 'package:contoh_modul6/services/payment_service.dart';
import 'package:intl/intl.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  List<PaymentModel> _all = [];
  bool _isLoading = true;
  String _error = '';
  late TabController _tabController;

  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPayments() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final payments = await PaymentService.getAllPayments();
      if (mounted) setState(() => _all = payments);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<PaymentModel> get _pending => _all.where((p) => p.status == 'pending').toList();
  List<PaymentModel> get _verified => _all.where((p) => p.status == 'success' || p.status == 'verified').toList();
  List<PaymentModel> get _rejected => _all.where((p) => p.status == 'failed' || p.status == 'rejected').toList();

  Future<void> _verifyPayment(PaymentModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verifikasi Pembayaran'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Verifikasi pembayaran ${_currency.format(p.amount)}?'),
          const SizedBox(height: 8),
          Text('Metode: ${p.methodLabel}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verifikasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await PaymentService.verifyPayment(p.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran diverifikasi'), backgroundColor: Colors.green),
        );
        _fetchPayments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectPayment(PaymentModel p) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pembayaran'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Tolak pembayaran ${_currency.format(p.amount)}?'),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Alasan penolakan (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (confirm != true) return;

    try {
      await PaymentService.rejectPayment(p.id!, reason: reasonController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran ditolak'), backgroundColor: Colors.orange),
        );
        _fetchPayments();
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
      case 'success':
      case 'verified': return Colors.green;
      case 'failed':
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildList(List<PaymentModel> payments, {bool showActions = false}) {
    if (payments.isEmpty) return const Center(child: Text('Tidak ada data'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: payments.length,
      itemBuilder: (ctx, i) {
        final p = payments[i];
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
                    Text(_currency.format(p.amount),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(p.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p.statusLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(Icons.payment, 'Metode', p.methodLabel),
                    if (p.createdAt != null)
                      _Row(Icons.access_time, 'Waktu', _dateFormat.format(p.createdAt!)),
                    if (p.proofImageUrl != null && p.proofImageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(children: [
                          const Icon(Icons.link, size: 14, color: Colors.blue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.proofImageUrl!,
                              style: const TextStyle(color: Colors.blue, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                    ],
                    if (p.notes != null && p.notes!.isNotEmpty)
                      _Row(Icons.note, 'Catatan', p.notes!),
                    if (showActions) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _verifyPayment(p),
                            icon: const Icon(Icons.verified, size: 16),
                            label: const Text('Verifikasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectPayment(p),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Tolak'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ]),
                    ],
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
        title: const Text('Verifikasi Pembayaran'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Verified (${_verified.length})'),
            Tab(text: 'Ditolak (${_rejected.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _fetchPayments, child: const Text('Coba Lagi')),
                ]))
              : RefreshIndicator(
                  onRefresh: _fetchPayments,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_pending, showActions: true),
                      _buildList(_verified),
                      _buildList(_rejected),
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
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}
