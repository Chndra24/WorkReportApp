import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/auth/presentation/providers/auth_provider.dart';
import 'package:workreport/features/employee/reports/data/work_report_repository.dart';
import 'package:workreport/core/models/work_report_model.dart';

/// Provider untuk mengambil seluruh laporan milik user
final userReportsStreamProvider = StreamProvider<List<WorkReportModel>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return Stream.value([]);
  return ref.watch(workReportRepositoryProvider).watchUserReports(user.id);
});

/// Provider untuk menyimpan halaman saat ini di Dashboard
final dashboardPageProvider = StateProvider<int>((ref) => 1);

/// Limit data per halaman
const int dashboardItemsPerPage = 5;

/// Provider untuk data yang sudah dipaginasi
final paginatedDashboardReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final reportsAsync = ref.watch(userReportsStreamProvider);
  final currentPage = ref.watch(dashboardPageProvider);

  return reportsAsync.whenData((reports) {
    final startIndex = (currentPage - 1) * dashboardItemsPerPage;
    final endIndex = startIndex + dashboardItemsPerPage;

    if (startIndex >= reports.length) return [];
    
    return reports.sublist(
      startIndex,
      endIndex > reports.length ? reports.length : endIndex,
    );
  });
});

/// Provider untuk menghitung total halaman
final dashboardTotalPagesProvider = Provider<int>((ref) {
  final reportsAsync = ref.watch(userReportsStreamProvider);
  return reportsAsync.maybeWhen(
    data: (reports) => (reports.length / dashboardItemsPerPage).ceil(),
    orElse: () => 0,
  );
});

/// Provider untuk menghitung ringkasan metrik (Total, Waiting, Approved, Rejected)
final dashboardMetricsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final reportsAsync = ref.watch(userReportsStreamProvider);

  return reportsAsync.whenData((reports) {
    return {
      'total': reports.length,
      'waiting': reports.where((r) => r.status == ReportStatus.waiting).length,
      'approved': reports.where((r) => r.status == ReportStatus.approved).length,
      'rejected': reports.where((r) => r.status == ReportStatus.rejected).length,
    };
  });
});
