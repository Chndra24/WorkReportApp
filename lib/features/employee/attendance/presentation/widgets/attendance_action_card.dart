import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../../../../../core/models/attendance_model.dart';
import '../../data/attendance_repository.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class AttendanceActionCard extends ConsumerWidget {
  const AttendanceActionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAttendanceAsync = ref.watch(todayAttendanceProvider);
    final user = ref.watch(authProvider).user;

    return todayAttendanceAsync.when(
      data: (attendance) {
        bool hasCheckedIn = attendance != null;
        bool hasCheckedOut = attendance?.clockOut != null;

        String statusText = "Belum Absen Masuk";
        if (hasCheckedIn) statusText = "Sudah Absen Masuk";
        if (hasCheckedOut) statusText = "Selesai Kerja";

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      !hasCheckedIn ? Icons.info_outline : Icons.check_circle_outline,
                      color: !hasCheckedIn ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Status: $statusText",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Tombol Absen Masuk
                ElevatedButton.icon(
                  onPressed: !hasCheckedIn
                      ? () => _handleCheckIn(context, ref, user!)
                      : null,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("ABSEN MASUK"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                // Tombol Absen Keluar
                ElevatedButton.icon(
                  onPressed: (hasCheckedIn && !hasCheckedOut)
                      ? () => _handleCheckOut(context, ref, user!)
                      : null,
                  icon: const Icon(Icons.logout),
                  label: const Text("ABSEN KELUAR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Gagal memuat status: $e")),
    );
  }

  Future<void> _handleCheckIn(BuildContext context, WidgetRef ref, dynamic user) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    
    final attendance = AttendanceModel(
      uid: user.id,
      employeeId: user.employeeId,
      dateStr: todayStr,
      clockIn: now,
      status: AttendanceModel.calculateStatus(now),
    );

    try {
      await ref.read(attendanceRepositoryProvider).checkIn(attendance);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil Absen Masuk!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context, WidgetRef ref, dynamic user) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    try {
      await ref.read(attendanceRepositoryProvider).checkOut(user.id, todayStr, now);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil Absen Keluar! Sampai jumpa besok.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
