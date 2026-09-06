import 'package:flutter/material.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:intl/intl.dart';
import 'package:workreport/features/employee/history/presentation/widgets/report_detail_sheet.dart';

class ReportItemCard extends StatelessWidget {
  final WorkReportModel report;

  const ReportItemCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ReportDetailSheet(report: report),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade200,
              child: report.imageUrl.isNotEmpty
                  ? Image.network(report.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
          title: Text(
            report.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(report.date),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          trailing: _buildStatusBadge(report.status),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ReportStatus.waiting:
        color = Colors.orange;
        label = "Menunggu";
        icon = Icons.access_time_filled;
        break;
      case ReportStatus.approved:
        color = Colors.green;
        label = "Disetujui";
        icon = Icons.check_circle;
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        label = "Ditolak";
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
