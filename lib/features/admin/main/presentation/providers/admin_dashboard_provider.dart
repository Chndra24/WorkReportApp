import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/core/models/user_model.dart';
import 'package:workreport/features/employee/reports/data/work_report_repository.dart';
import 'package:workreport/features/admin/employee/presentation/providers/employee_provider.dart';
import 'package:workreport/features/admin/activation/data/staff_activation_repository.dart';

/// Provider untuk mengambil semua laporan (Admin)
final allWorkReportsStreamProvider = StreamProvider<List<WorkReportModel>>((ref) {
  return ref.watch(workReportRepositoryProvider).watchAllReports();
});

/// Provider untuk mengambil semua staf belum aktivasi
final pendingActivationStaffStreamProvider = StreamProvider<List<UserData>>((ref) {
  return ref.watch(staffActivationRepositoryProvider).watchPendingActivationStaff();
});

/// Provider untuk menghitung metrik Dashboard Admin
final adminDashboardMetricsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final reportsAsync = ref.watch(allWorkReportsStreamProvider);
  final employeesAsync = ref.watch(verifiedEmployeesProvider);
  final pendingStaffAsync = ref.watch(pendingActivationStaffStreamProvider);

  // Menggabungkan status loading/error
  if (reportsAsync.isLoading || employeesAsync.isLoading || pendingStaffAsync.isLoading) {
    return const AsyncValue.loading();
  }
  
  if (reportsAsync.hasError) return AsyncValue.error(reportsAsync.error!, reportsAsync.stackTrace!);

  return AsyncValue.data({
    'totalReports': reportsAsync.value?.length ?? 0,
    'needReview': reportsAsync.value?.where((r) => r.status == ReportStatus.waiting).length ?? 0,
    'pendingActivation': pendingStaffAsync.value?.length ?? 0,
    'activeStaff': employeesAsync.value?.where((e) => e.status == UserStatus.aktif || e.status == UserStatus.cuti).length ?? 0,
  });
});

/// Provider untuk antrian laporan menunggu tinjauan (Pagination)
final adminDashboardPageProvider = StateProvider<int>((ref) => 1);
const int adminDashboardItemsPerPage = 5;

final pendingReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final reportsAsync = ref.watch(allWorkReportsStreamProvider);
  
  return reportsAsync.whenData((reports) {
    return reports.where((r) => r.status == ReportStatus.waiting).toList();
  });
});

final paginatedPendingReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final pendingAsync = ref.watch(pendingReportsProvider);
  final currentPage = ref.watch(adminDashboardPageProvider);

  return pendingAsync.whenData((reports) {
    final startIndex = (currentPage - 1) * adminDashboardItemsPerPage;
    final endIndex = startIndex + adminDashboardItemsPerPage;
    if (startIndex >= reports.length) return [];
    return reports.sublist(startIndex, endIndex > reports.length ? reports.length : endIndex);
  });
});

final adminDashboardTotalPagesProvider = Provider<int>((ref) {
  final pendingAsync = ref.watch(pendingReportsProvider);
  return pendingAsync.maybeWhen(
    data: (reports) => (reports.length / adminDashboardItemsPerPage).ceil(),
    orElse: () => 0,
  );
});
