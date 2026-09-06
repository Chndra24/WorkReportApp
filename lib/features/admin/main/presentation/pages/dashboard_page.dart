import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/admin/presentation/widgets/metric_card.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_report_detail_sheet.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(adminDashboardMetricsProvider);
    final pendingReportsAsync = ref.watch(paginatedPendingReportsProvider);
    final currentPage = ref.watch(adminDashboardPageProvider);
    final totalPages = ref.watch(adminDashboardTotalPagesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "MONITORING LAPORAN PEKERJAAN & STAF",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 16),
          
          // Grid Metrik
          metricsAsync.when(
            data: (m) => GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: <Widget>[
                MetricCard(title: "Total Laporan", value: m['totalReports'].toString(), icon: Icons.assignment_outlined, color: Colors.blue),
                MetricCard(title: "Perlu Ditinjau", value: m['needReview'].toString(), icon: Icons.pending_actions_outlined, color: Colors.orange),
                MetricCard(title: "Menunggu Aktivasi", value: m['pendingActivation'].toString(), icon: Icons.person_add_alt_1, color: Colors.green),
                MetricCard(title: "Total Staf Aktif", value: m['activeStaff'].toString(), icon: Icons.people_outline, color: Colors.purple),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error: $e"),
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ANTRIAN LAPORAN MENUNGGU TINJAUAN",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              if (totalPages > 1)
                Text("Hal. $currentPage/$totalPages", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          
          // List Antrian
          pendingReportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text("Semua laporan telah ditinjau.")));
              }
              return Column(
                children: [
                  ...reports.map((report) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: const Icon(Icons.description_outlined, color: Colors.indigo),
                      ),
                      title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Oleh: ${report.employeeName}", style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text("(${report.employeeId})", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(DateFormat('dd/MM/yyyy').format(report.date), style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () => _showReviewSheet(context, report),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero, // Padding nol agar muat di SizedBox kecil
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("REVIEW", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  )),
                  
                  // Pagination
                  if (totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: currentPage > 1 ? () => ref.read(adminDashboardPageProvider.notifier).state-- : null, icon: const Icon(Icons.chevron_left)),
                        const SizedBox(width: 20),
                        IconButton(onPressed: currentPage < totalPages ? () => ref.read(adminDashboardPageProvider.notifier).state++ : null, icon: const Icon(Icons.chevron_right)),
                      ],
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Gagal memuat antrian: $e")),
          ),
        ],
      ),
    );
  }

  void _showReviewSheet(BuildContext context, dynamic report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminReportDetailSheet(report: report),
    );
  }
}
