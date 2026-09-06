import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/employee/main/presentation/providers/employee_navigation_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/user_metric_card.dart';
import '../widgets/report_item_card.dart';

class EmployeeDashboardPage extends ConsumerWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final reportsAsync = ref.watch(userReportsStreamProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Laporan Kerja",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Grid Metrik
          metricsAsync.when(
            data: (metrics) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                UserMetricCard(title: 'Total Laporan', value: metrics['total'].toString(), color: Colors.indigo, icon: Icons.assignment_outlined),
                UserMetricCard(title: 'Menunggu', value: metrics['waiting'].toString(), color: Colors.orange, icon: Icons.pending_actions_outlined),
                UserMetricCard(title: 'Disetujui', value: metrics['approved'].toString(), color: Colors.green, icon: Icons.task_alt_outlined),
                UserMetricCard(title: 'Ditolak', value: metrics['rejected'].toString(), color: Colors.red, icon: Icons.unpublished_outlined),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error metrik: $e"),
          ),
          
          const SizedBox(height: 24),
          
          // Header Laporan Terbaru dengan Tombol Lihat Semua
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Laporan Pekerjaan Terbaru",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(employeeNavigationProvider.notifier).state = EmployeeMenu.riwayatKerja;
                },
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // List Laporan (Hanya 5 Terbaru)
          reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("Belum ada laporan kerja."),
                  ),
                );
              }
              
              // Mengambil maksimal 5 laporan terbaru
              final latestReports = reports.take(5).toList();
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: latestReports.length,
                itemBuilder: (context, index) {
                  return ReportItemCard(report: latestReports[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Gagal memuat laporan: $e")),
          ),
        ],
      ),
    );
  }
}
