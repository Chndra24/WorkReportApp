import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/features/admin/main/presentation/providers/admin_dashboard_provider.dart';

/// Provider untuk pencarian di halaman Tinjau Laporan
final reviewSearchProvider = StateProvider<String>((ref) => "");

/// Provider untuk filter status
final reviewStatusFilterProvider = StateProvider<ReportStatus?>((ref) => null);

/// Provider untuk filter tanggal (null berarti semua waktu)
final reviewDateFilterProvider = StateProvider<DateTime?>((ref) => null);

/// Provider untuk halaman aktif
final reviewPageProvider = StateProvider<int>((ref) => 1);
const int reviewItemsPerPage = 10;

/// Provider utama untuk daftar laporan yang difilter
final filteredReviewReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final allReportsAsync = ref.watch(allWorkReportsStreamProvider);
  final searchQuery = ref.watch(reviewSearchProvider).toLowerCase();
  final statusFilter = ref.watch(reviewStatusFilterProvider);
  final dateFilter = ref.watch(reviewDateFilterProvider);

  return allReportsAsync.whenData((reports) {
    return reports.where((report) {
      final matchesTitle = report.title.toLowerCase().contains(searchQuery);
      final matchesName = report.employeeName.toLowerCase().contains(searchQuery);
      final matchesStatus = statusFilter == null || report.status == statusFilter;
      
      // Filter Tanggal
      bool matchesDate = true;
      if (dateFilter != null) {
        matchesDate = report.date.year == dateFilter.year &&
                      report.date.month == dateFilter.month &&
                      report.date.day == dateFilter.day;
      }
      
      return (matchesTitle || matchesName) && matchesStatus && matchesDate;
    }).toList();
  });
});

/// Provider untuk paginasi
final paginatedReviewReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final filteredAsync = ref.watch(filteredReviewReportsProvider);
  final currentPage = ref.watch(reviewPageProvider);

  return filteredAsync.whenData((reports) {
    final startIndex = (currentPage - 1) * reviewItemsPerPage;
    final endIndex = startIndex + reviewItemsPerPage;
    if (startIndex >= reports.length) return [];
    return reports.sublist(startIndex, endIndex > reports.length ? reports.length : endIndex);
  });
});

/// Total Halaman
final reviewTotalPagesProvider = Provider<int>((ref) {
  final filteredAsync = ref.watch(filteredReviewReportsProvider);
  return filteredAsync.maybeWhen(
    data: (reports) => (reports.length / reviewItemsPerPage).ceil(),
    orElse: () => 0,
  );
});
