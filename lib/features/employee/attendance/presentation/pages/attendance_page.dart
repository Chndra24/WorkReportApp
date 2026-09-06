import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/attendance_history_tile.dart';
import '../../../../../core/models/attendance_model.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockAsync = ref.watch(realTimeClockProvider);
    final historyAsync = ref.watch(attendanceHistoryStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Judul & Jam Real-Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PRESENSI KERJA",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  Text(
                    "Harian",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              clockAsync.when(
                data: (now) => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('HH:mm:ss').format(now),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      DateFormat('EEE, d MMM yyyy', 'id_ID').format(now),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Icon(Icons.error_outline),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const AttendanceActionCard(),
          
          const SizedBox(height: 32),
          const Text(
            "Riwayat Presensi Bulan Ini",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada riwayat presensi."),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final data = history[index];
                  return AttendanceHistoryTile(
                    data: {
                      'date': DateFormat('dd MMM yyyy').format(data.clockIn!),
                      'in': DateFormat('HH:mm').format(data.clockIn!),
                      'out': data.clockOut != null ? DateFormat('HH:mm').format(data.clockOut!) : '--:--',
                      'status': data.status == AttendanceStatus.tepatWaktu ? 'Tepat Waktu' : 'Terlambat',
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Gagal memuat riwayat: $e")),
          ),
        ],
      ),
    );
  }
}
