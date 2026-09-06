import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/features/employee/reports/data/work_report_repository.dart';

class AdminReportDetailSheet extends ConsumerWidget {
  final WorkReportModel report;

  const AdminReportDetailSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text("Oleh: ${report.employeeName}", style: const TextStyle(color: Colors.indigo, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text(report.employeeId, style: TextStyle(color: Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(report.status),
              ],
            ),
            const Divider(height: 32),

            _buildInfoRow(Icons.calendar_today_outlined, "Tanggal", DateFormat('dd MMMM yyyy', 'id_ID').format(report.date)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, "Lokasi", report.location),
            const SizedBox(height: 24),
            
            const Text("Deskripsi Pekerjaan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Text(report.description, style: const TextStyle(height: 1.5)),
            ),
            const SizedBox(height: 24),

            const Text("Foto Hasil Kerja:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: report.imageUrl.isNotEmpty
                  ? Image.network(
                      report.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : Container(height: 200, color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator())),
                    )
                  : Container(height: 100, color: Colors.grey.shade100, child: const Center(child: Text("Tidak ada foto"))),
            ),
            
            const SizedBox(height: 32),

            // ACTION BUTTONS (Sesuai Status)
            _buildActionButtons(context, ref),

            const SizedBox(height: 12),
            
            // CLOSE BUTTON
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Tutup Detail", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    if (report.status == ReportStatus.waiting) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleAction(context, ref, ReportStatus.rejected),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text("TOLAK", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleAction(context, ref, ReportStatus.approved),
              icon: const Icon(Icons.check),
              label: const Text("SETUJUI"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    } else if (report.status == ReportStatus.approved) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleAction(context, ref, ReportStatus.rejected),
          icon: const Icon(Icons.refresh, color: Colors.red),
          label: const Text("UBAH STATUS KE: TOLAK / REVISI", style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else {
      // Status Rejected
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleAction(context, ref, ReportStatus.approved),
          icon: const Icon(Icons.check, color: Colors.green),
          label: const Text("UBAH STATUS KE: SETUJUI", style: TextStyle(color: Colors.green)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, ReportStatus status) async {
    try {
      await ref.read(workReportRepositoryProvider).updateReportStatus(report.id, status);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == ReportStatus.approved ? "Laporan telah disetujui" : "Laporan telah ditolak/revisi"),
            backgroundColor: status == ReportStatus.approved ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ]),
      ],
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color = Colors.orange;
    String label = "Menunggu";
    if (status == ReportStatus.approved) { color = Colors.green; label = "Disetujui"; }
    if (status == ReportStatus.rejected) { color = Colors.red; label = "Ditolak"; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
