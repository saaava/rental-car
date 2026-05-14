import 'package:flutter/material.dart';
import 'package:contoh_modul6/models/car_model.dart';
import 'package:intl/intl.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBook;

  const CarCard({
    super.key,
    required this.car,
    this.onEdit,
    this.onDelete,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(car.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${car.brand} • ${car.year}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: car.isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(car.isAvailable ? 'Tersedia' : 'Disewa',
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(children: [
                  _Chip(Icons.settings, car.transmission),
                  const SizedBox(width: 8),
                  _Chip(Icons.local_gas_station, car.fuel),
                  const SizedBox(width: 8),
                  _Chip(Icons.people, '${car.seats} seat'),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (car.location != null)
                      Expanded(
                        child: Row(children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(car.location!,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                      )
                    else const Spacer(),
                    Text(currency.format(car.pricePerDay) + '/hari',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                if (car.rating != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${car.rating!.toStringAsFixed(1)} (${car.totalReviews ?? 0} ulasan)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ],
                if (onEdit != null || onDelete != null || onBook != null) ...[
                  const Divider(height: 16),
                  Row(
                    children: [
                      if (onBook != null && car.isAvailable)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onBook,
                            icon: const Icon(Icons.calendar_month, size: 16),
                            label: const Text('Sewa'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A2E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      if (onEdit != null) ...[
                        if (onBook != null && car.isAvailable) const SizedBox(width: 8),
                        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Color(0xFF1A1A2E)), tooltip: 'Edit'),
                      ],
                      if (onDelete != null)
                        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Hapus'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ]),
    );
  }
}
