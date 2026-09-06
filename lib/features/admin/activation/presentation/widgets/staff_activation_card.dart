import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/user_model.dart';
import 'package:workreport/features/admin/activation/providers/staff_activation_provider.dart';

class StaffActivationCard extends ConsumerWidget {
  final UserData userData;

  const StaffActivationCard({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      userData.employeeId,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showConfirmationDialog(
                    context,
                    ref,
                    title: 'Tolak Aktivasi',
                    content: 'Apakah Anda yakin ingin menolak pengajuan akun ${userData.name}?',
                    onConfirm: () => ref.read(staffActivationActionProvider).reject(userData.id),
                    isDestructive: true,
                  ),
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Tolak',
                ),
                IconButton(
                  onPressed: () => _showConfirmationDialog(
                    context,
                    ref,
                    title: 'Setujui Aktivasi',
                    content: 'Apakah Anda yakin ingin mengaktifkan akun ${userData.name}?',
                    onConfirm: () => ref.read(staffActivationActionProvider).approve(userData.id),
                    isDestructive: false,
                  ),
                  icon: const Icon(Icons.check, color: Colors.green),
                  tooltip: 'Setujui',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
    required bool isDestructive,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await onConfirm();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isDestructive ? 'Aktivasi ditolak' : 'Aktivasi disetujui'),
                    backgroundColor: isDestructive ? Colors.red : Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Terjadi kesalahan: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isDestructive ? 'Ya, Tolak' : 'Ya, Setujui'),
          ),
        ],
      ),
    );
  }
}
