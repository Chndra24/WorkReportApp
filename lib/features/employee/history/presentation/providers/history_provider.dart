import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/features/employee/dashboard/presentation/providers/dashboard_provider.dart';

/// Provider untuk menyimpan query pencarian di Riwayat
final historySearchProvider = StateProvider<String>((ref) => "");

/// Provider untuk menyimpan filter status di Riwayat
final historyStatusFilterProvider = StateProvider<ReportStatus?>((ref) => null);

/// Provider untuk menyimpan filter tanggal di Riwayat (null berarti semua waktu)
final historyDateFilterProvider = StateProvider<DateTime?>((ref) => null);

/// Provider untuk menyimpan halaman saat ini di Riwayat
final historyPageProvider = StateProvider<int>((ref) => 1);

/// Limit data per halaman riwayat
const int historyItemsPerPage = 10;

/// Provider untuk daftar laporan yang sudah difilter (Search, Status, & Tanggal)
final filteredHistoryReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final allReportsAsync = ref.watch(userReportsStreamProvider);
  final searchQuery = ref.watch(historySearchProvider).toLowerCase();
  final statusFilter = ref.watch(historyStatusFilterProvider);
  final dateFilter = ref.watch(historyDateFilterProvider);

  return allReportsAsync.whenData((reports) {
    return reports.where((report) {
      final matchesSearch = report.title.toLowerCase().contains(searchQuery);
      final matchesStatus = statusFilter == null || report.status == statusFilter;
      
      // Filter Tanggal
      bool matchesDate = true;
      if (dateFilter != null) {
        matchesDate = report.date.year == dateFilter.year &&
                      report.date.month == dateFilter.month &&
                      report.date.day == dateFilter.day;
      }
      
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  });
});

/// Provider untuk data riwayat yang sudah dipaginasi
final paginatedHistoryReportsProvider = Provider<AsyncValue<List<WorkReportModel>>>((ref) {
  final filteredAsync = ref.watch(filteredHistoryReportsProvider);
  final currentPage = ref.watch(historyPageProvider);

  return filteredAsync.whenData((reports) {
    final startIndex = (currentPage - 1) * historyItemsPerPage;
    final endIndex = startIndex + historyItemsPerPage;

    if (startIndex >= reports.length) return [];
    
    return reports.sublist(
      startIndex,
      endIndex > reports.length ? reports.length : endIndex,
    );
  });
});

/// Provider untuk menghitung total halaman riwayat
final historyTotalPagesProvider = Provider<int>((ref) {
  final filteredAsync = ref.watch(filteredHistoryReportsProvider);
  return filteredAsync.maybeWhen(
    data: (reports) => (reports.length / historyItemsPerPage).ceil(),
    orElse: () => 0,
  );
});
