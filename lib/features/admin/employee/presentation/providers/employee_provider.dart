import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/admin/employee/data/employee_repository.dart';
import 'package:workreport/core/models/user_model.dart';

/// Provider untuk mengambil data karyawan terverifikasi
final verifiedEmployeesProvider = StreamProvider<List<UserData>>((ref) {
  return ref.watch(employeeRepositoryProvider).watchVerifiedEmployees();
});

/// Provider untuk menyimpan query pencarian
final employeeSearchProvider = StateProvider<String>((ref) => "");

/// Provider untuk menyimpan filter status
final employeeStatusFilterProvider = StateProvider<UserStatus?>((ref) => null);

/// Provider untuk menyimpan halaman saat ini
final employeeCurrentPageProvider = StateProvider<int>((ref) => 1);

/// Jumlah data per halaman
const int itemsPerPage = 10;

/// Provider untuk memfilter dan mempaginasi daftar karyawan
final filteredEmployeesProvider = Provider<AsyncValue<List<UserData>>>((ref) {
  final employeesAsync = ref.watch(verifiedEmployeesProvider);
  final searchQuery = ref.watch(employeeSearchProvider).toLowerCase();
  final statusFilter = ref.watch(employeeStatusFilterProvider);

  return employeesAsync.whenData((employees) {
    // 1. Filter berdasarkan pencarian dan status
    final filteredList = employees.where((employee) {
      final nameMatch = employee.name.toLowerCase().contains(searchQuery);
      final idMatch = employee.employeeId.toLowerCase().contains(searchQuery);
      final statusMatch = statusFilter == null || employee.status == statusFilter;
      return (nameMatch || idMatch) && statusMatch;
    }).toList();

    return filteredList;
  });
});

/// Provider untuk mengambil data yang sudah dipaginasi
final paginatedEmployeesProvider = Provider<AsyncValue<List<UserData>>>((ref) {
  final filteredAsync = ref.watch(filteredEmployeesProvider);
  final currentPage = ref.watch(employeeCurrentPageProvider);

  return filteredAsync.whenData((employees) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= employees.length) return [];
    
    return employees.sublist(
      startIndex,
      endIndex > employees.length ? employees.length : endIndex,
    );
  });
});

/// Provider untuk menghitung total halaman
final totalPagesProvider = Provider<int>((ref) {
  final filteredAsync = ref.watch(filteredEmployeesProvider);
  return filteredAsync.maybeWhen(
    data: (employees) => (employees.length / itemsPerPage).ceil(),
    orElse: () => 0,
  );
});

