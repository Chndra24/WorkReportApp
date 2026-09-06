import 'package:flutter/material.dart';

class AttendanceHistoryTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const AttendanceHistoryTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isLate = data['status'] == 'Terlambat';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Tanggal
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tanggal", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(data['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Jam
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _timeInfo("Masuk", data['in']),
                  const SizedBox(width: 16),
                  _timeInfo("Keluar", data['out']),
                ],
              ),
            ),
            // Status
            _statusBadge(data['status'], isLate),
          ],
        ),
      ),
    );
  }

  Widget _timeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _statusBadge(String label, bool isLate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLate ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isLate ? Colors.red.shade800 : Colors.green.shade800,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
