import 'package:flutter/material.dart';
import 'package:workreport/core/models/user_model.dart';
import 'package:workreport/features/admin/employee/presentation/widgets/status_edit_dialog.dart';

class EmployeeTileWidget extends StatelessWidget {
  final UserData employee;

  const EmployeeTileWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Text(
            employee.name.isNotEmpty ? employee.name[0].toUpperCase() : "?",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.email,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                employee.employeeId,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(employee.status ?? UserStatus.belumDiatur),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => StatusEditDialog(employee: employee),
                );
              },
            ),
          ],
        ),
        onTap: () {
          // Klik kartu untuk detail jika diperlukan di masa depan
        },
      ),
    );
  }

  Widget _buildStatusBadge(UserStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case UserStatus.aktif:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = "Aktif";
        break;
      case UserStatus.cuti:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        label = "Cuti";
        break;
      case UserStatus.nonAktif:
        bgColor = Colors.grey.shade300;
        textColor = Colors.black87;
        label = "Non-Aktif";
        break;
      case UserStatus.belumDiatur:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = "Belum Diatur";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
