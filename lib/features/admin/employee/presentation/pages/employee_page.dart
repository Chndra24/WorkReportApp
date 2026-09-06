import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/user_model.dart';
import 'package:workreport/features/admin/employee/presentation/providers/employee_provider.dart';
import 'package:workreport/features/admin/employee/presentation/widgets/employee_tile_widget.dart';

class EmployeePage extends ConsumerWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedEmployees = ref.watch(paginatedEmployeesProvider);
    final currentPage = ref.watch(employeeCurrentPageProvider);
    final totalPages = ref.watch(totalPagesProvider);
    final selectedStatus = ref.watch(employeeStatusFilterProvider);

    return Column(
      children: [
        // Header & Filters
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daftar Karyawan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (value) {
                        ref.read(employeeSearchProvider.notifier).state = value;
                        ref.read(employeeCurrentPageProvider.notifier).state = 1;
                      },
                      decoration: InputDecoration(
                        hintText: "Cari nama/ID...",
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Status
                  Expanded(
                    child: DropdownButtonFormField<UserStatus?>(
                      value: selectedStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      hint: const Text("Status"),
                      items: [
                        const DropdownMenuItem(value: null, child: Text("Semua")),
                        ...UserStatus.values.map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusLabel(status)),
                            )),
                      ],
                      onChanged: (value) {
                        ref.read(employeeStatusFilterProvider.notifier).state = value;
                        ref.read(employeeCurrentPageProvider.notifier).state = 1;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List View
        Expanded(
          child: paginatedEmployees.when(
            data: (employees) {
              if (employees.isEmpty) {
                return const Center(child: Text("Tidak ada data ditemukan."));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: employees.length,
                itemBuilder: (context, index) => EmployeeTileWidget(employee: employees[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text("Error: $error")),
          ),
        ),

        // Pagination Controls
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Halaman $currentPage dari $totalPages",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: currentPage > 1
                          ? () => ref.read(employeeCurrentPageProvider.notifier).state--
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      style: IconButton.styleFrom(
                        backgroundColor: currentPage > 1 ? Colors.indigo.shade50 : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: currentPage < totalPages
                          ? () => ref.read(employeeCurrentPageProvider.notifier).state++
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      style: IconButton.styleFrom(
                        backgroundColor: currentPage < totalPages ? Colors.indigo.shade50 : Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
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
