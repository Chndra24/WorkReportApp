import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/features/employee/dashboard/presentation/widgets/report_item_card.dart';
import '../providers/history_provider.dart';

class ReportHistoryPage extends ConsumerWidget {
  const ReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedReportsAsync = ref.watch(paginatedHistoryReportsProvider);
    final currentPage = ref.watch(historyPageProvider);
    final totalPages = ref.watch(historyTotalPagesProvider);
    final selectedStatus = ref.watch(historyStatusFilterProvider);
    final selectedDate = ref.watch(historyDateFilterProvider);

    return Column(
      children: [
        // Filter Area
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Riwayat Laporan Kerja",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              TextField(
                onChanged: (value) {
                  ref.read(historySearchProvider.notifier).state = value;
                  ref.read(historyPageProvider.notifier).state = 1;
                },
                decoration: InputDecoration(
                  hintText: "Cari judul pekerjaan...",
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Filter Status
                  Expanded(
                    child: DropdownButtonFormField<ReportStatus?>(
                      value: selectedStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      hint: const Text("Status"),
                      items: [
                        const DropdownMenuItem(value: null, child: Text("Semua Status")),
                        ...ReportStatus.values.map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusLabel(status)),
                            )),
                      ],
                      onChanged: (value) {
                        ref.read(historyStatusFilterProvider.notifier).state = value;
                        ref.read(historyPageProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Tanggal
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, ref, selectedDate),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedDate == null ? "Semua Waktu" : DateFormat('dd MMM yyyy').format(selectedDate),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (selectedDate != null)
                              GestureDetector(
                                onTap: () {
                                  ref.read(historyDateFilterProvider.notifier).state = null;
                                  ref.read(historyPageProvider.notifier).state = 1;
                                },
                                child: const Icon(Icons.close, size: 16, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List Area
        Expanded(
          child: paginatedReportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(child: Text("Tidak ada laporan ditemukan."));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reports.length,
                itemBuilder: (context, index) => ReportItemCard(report: reports[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
          ),
        ),

        // Pagination Bar
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Halaman $currentPage dari $totalPages", style: const TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(
                      onPressed: currentPage > 1 ? () => ref.read(historyPageProvider.notifier).state-- : null,
                      icon: const Icon(Icons.chevron_left),
                      style: IconButton.styleFrom(backgroundColor: currentPage > 1 ? Colors.indigo.shade50 : Colors.grey.shade100),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: currentPage < totalPages ? () => ref.read(historyPageProvider.notifier).state++ : null,
                      icon: const Icon(Icons.chevron_right),
                      style: IconButton.styleFrom(backgroundColor: currentPage < totalPages ? Colors.indigo.shade50 : Colors.grey.shade100),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref, DateTime? currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(historyDateFilterProvider.notifier).state = picked;
      ref.read(historyPageProvider.notifier).state = 1;
    }
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.waiting: return "Menunggu";
      case ReportStatus.approved: return "Disetujui";
      case ReportStatus.rejected: return "Ditolak";
    }
  }
}
