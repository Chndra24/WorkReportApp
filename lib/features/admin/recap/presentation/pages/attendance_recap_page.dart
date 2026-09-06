import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workreport/features/admin/recap/presentation/providers/recap_provider.dart';
import 'package:workreport/features/admin/recap/presentation/widgets/attendance_recap_card.dart';

class AttendanceRecapPage extends ConsumerWidget {
  const AttendanceRecapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recapAsync = ref.watch(attendanceRecapProvider);
    final selectedDate = ref.watch(selectedRecapDateProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rekap Absensi Karyawan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => ref.read(recapSearchProvider.notifier).state = value,
                      decoration: InputDecoration(
                        hintText: "Cari nama/ID...",
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Menggunakan Flexible agar tombol tidak mencoba mengambil lebar tak terbatas
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectDate(context, ref, selectedDate),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        DateFormat('dd MMM').format(selectedDate),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: recapAsync.when(
            data: (recapItems) {
              if (recapItems.isEmpty) {
                return const Center(child: Text("Tidak ada data karyawan ditemukan."));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recapItems.length,
                itemBuilder: (context, index) {
                  return AttendanceRecapCard(item: recapItems[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Terjadi kesalahan: $err")),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != currentDate) {
      ref.read(selectedRecapDateProvider.notifier).state = picked;
    }
  }
}
