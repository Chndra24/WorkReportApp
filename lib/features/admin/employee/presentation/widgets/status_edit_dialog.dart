import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/user_model.dart';
import 'package:workreport/features/admin/employee/data/employee_repository.dart';

class StatusEditDialog extends ConsumerWidget {
  final UserData employee;

  const StatusEditDialog({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text("Edit Status: ${employee.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pilih Status Baru:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ...UserStatus.values.map((status) {
            return RadioListTile<UserStatus>(
              title: Text(_getStatusLabel(status)),
              value: status,
              groupValue: employee.status,
              onChanged: (value) => _updateStatus(context, ref, value),
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, UserStatus? newStatus) async {
    if (newStatus == null) return;
    try {
      await ref.read(employeeRepositoryProvider).updateEmployeeStatus(employee.id, newStatus);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _getStatusLabel(UserStatus status) {
    switch (status) {
      case UserStatus.aktif: return "Aktif";
      case UserStatus.cuti: return "Cuti";
      case UserStatus.nonAktif: return "Non-Aktif";
      case UserStatus.belumDiatur: return "Baru";
    }
  }
}
