import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workreport/features/admin/recap/presentation/providers/recap_provider.dart';

class AttendanceRecapCard extends StatelessWidget {
  final RecapItem item;

  const AttendanceRecapCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isHadir = item.attendance != null;
    final String jamMasuk = item.attendance?.clockIn != null 
        ? DateFormat('HH:mm').format(item.attendance!.clockIn!) + " WIB"
        : "--:--";
    final String jamKeluar = item.attendance?.clockOut != null 
        ? DateFormat('HH:mm').format(item.attendance!.clockOut!) + " WIB"
        : "--:--";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.employee.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                        child: Text(item.employee.employeeId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(isHadir),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildTimeInfo("Jam Masuk", jamMasuk, Icons.login, Colors.green),
                const SizedBox(width: 32),
                _buildTimeInfo("Jam Keluar", jamKeluar, Icons.logout, Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(time, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isHadir) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHadir ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isHadir ? "Hadir" : "Alpa",
        style: TextStyle(
          color: isHadir ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
