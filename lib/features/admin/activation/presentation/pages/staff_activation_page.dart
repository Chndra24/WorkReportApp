import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/admin/activation/providers/staff_activation_provider.dart';
import '../widgets/staff_activation_card.dart';

class StaffActivationPage extends ConsumerWidget {
  const StaffActivationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffStream = ref.watch(staffActivationStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VERIFIKASI AKUN STAF BARU',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'MENUNGGU AKTIVASI',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: staffStream.when(
              data: (staffList) {
                if (staffList.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.builder(
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    return StaffActivationCard(userData: staffList[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Terjadi kesalahan: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada pengajuan aktivasi staf baru',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
