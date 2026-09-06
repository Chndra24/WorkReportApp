import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/features/admin/main/presentation/widgets/admin_report_detail_sheet.dart';
import '../providers/review_provider.dart';

class ReviewReportPage extends ConsumerWidget {
  const ReviewReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedReportsAsync = ref.watch(paginatedReviewReportsProvider);
    final currentPage = ref.watch(reviewPageProvider);
    final totalPages = ref.watch(reviewTotalPagesProvider);
    final selectedStatus = ref.watch(reviewStatusFilterProvider);
    final selectedDate = ref.watch(reviewDateFilterProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tinjau Laporan Kerja",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              TextField(
                onChanged: (value) {
                  ref.read(reviewSearchProvider.notifier).state = value;
                  ref.read(reviewPageProvider.notifier).state = 1;
                },
                decoration: InputDecoration(
                  hintText: "Cari judul atau nama karyawan...",
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              
              // Filter Row (Status & Tanggal)
              Row(
                children: [
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
                        ref.read(reviewStatusFilterProvider.notifier).state = value;
                        ref.read(reviewPageProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
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
                                  ref.read(reviewDateFilterProvider.notifier).state = null;
                                  ref.read(reviewPageProvider.notifier).state = 1;
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

        Expanded(
          child: paginatedReportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(child: Text("Tidak ada laporan ditemukan."));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(report.status).withOpacity(0.1),
                        child: Icon(Icons.description_outlined, color: _getStatusColor(report.status)),
                      ),
                      title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Oleh: ${report.employeeName}", style: const TextStyle(fontSize: 12, color: Colors.indigo)),
                              const SizedBox(width: 4),
                              Text("(${report.employeeId})", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(DateFormat('dd MMMM yyyy', 'id_ID').format(report.date), style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      onTap: () => _showReviewSheet(context, report),
                    ),
                  );
                },
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Halaman $currentPage dari $totalPages", style: const TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(onPressed: currentPage > 1 ? () => ref.read(reviewPageProvider.notifier).state-- : null, icon: const Icon(Icons.chevron_left)),
                    const SizedBox(width: 8),
                    IconButton(onPressed: currentPage < totalPages ? () => ref.read(reviewPageProvider.notifier).state++ : null, icon: const Icon(Icons.chevron_right)),
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
      ref.read(reviewDateFilterProvider.notifier).state = picked;
      ref.read(reviewPageProvider.notifier).state = 1;
    }
  }

  void _showReviewSheet(BuildContext context, WorkReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminReportDetailSheet(report: report),
    );
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.waiting: return "Menunggu";
      case ReportStatus.approved: return "Disetujui";
      case ReportStatus.rejected: return "Ditolak";
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.waiting: return Colors.orange;
      case ReportStatus.approved: return Colors.green;
      case ReportStatus.rejected: return Colors.red;
    }
  }
}
