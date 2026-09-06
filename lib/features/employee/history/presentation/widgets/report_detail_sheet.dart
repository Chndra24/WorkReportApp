import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workreport/core/models/work_report_model.dart';

class ReportDetailSheet extends StatelessWidget {
  final WorkReportModel report;

  const ReportDetailSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
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
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Header: Judul & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusBadge(report.status),
              ],
            ),
            const Divider(height: 32),

            // Info Section (Tanggal & Lokasi)
            _buildInfoRow(Icons.calendar_today_outlined, "Tanggal", DateFormat('dd MMMM yyyy', 'id_ID').format(report.date)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, "Lokasi Kerja", report.location),
            
            const SizedBox(height: 24),
            
            // Deskripsi Section
            const Text("Deskripsi Pekerjaan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Text(
                report.description,
                style: const TextStyle(color: Colors.black87, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 24),

            // Foto Section
            const Text("Foto Hasil Kerja:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: report.imageUrl.isNotEmpty
                  ? Image.network(
                      report.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey.shade100,
                      child: const Center(child: Text("Tidak ada foto")),
                    ),
            ),
            const SizedBox(height: 30),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Tutup Detail"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        )
      ],
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color;
    String label;
    switch (status) {
      case ReportStatus.waiting: color = Colors.orange; label = "Menunggu"; break;
      case ReportStatus.approved: color = Colors.green; label = "Disetujui"; break;
      case ReportStatus.rejected: color = Colors.red; label = "Ditolak"; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
