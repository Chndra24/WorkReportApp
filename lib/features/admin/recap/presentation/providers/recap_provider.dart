import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workreport/features/admin/recap/data/recap_repository.dart';
import 'package:workreport/features/admin/employee/presentation/providers/employee_provider.dart';
import 'package:workreport/core/models/attendance_model.dart';
import 'package:workreport/core/models/user_model.dart';

/// Provider untuk menyimpan tanggal yang dipilih admin
final selectedRecapDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider untuk menyimpan query pencarian nama/ID
final recapSearchProvider = StateProvider<String>((ref) => "");

/// Provider khusus untuk mengambil data absen berdasarkan tanggal (Family)
final dailyAttendanceStreamProvider = StreamProvider.family<List<AttendanceModel>, String>((ref, dateStr) {
  return ref.watch(recapRepositoryProvider).watchAllAttendanceByDate(dateStr);
});

/// Model untuk menggabungkan data User dan Absensi
class RecapItem {
  final UserData employee;
  final AttendanceModel? attendance;
  RecapItem({required this.employee, this.attendance});
}

/// Provider utama untuk menghasilkan list Rekap (Hadir/Alpa)
final attendanceRecapProvider = Provider<AsyncValue<List<RecapItem>>>((ref) {
  // 1. Ambil daftar karyawan terverifikasi
  final employeesAsync = ref.watch(verifiedEmployeesProvider);
  
  // 2. Ambil data absen pada tanggal yang dipilih
  final date = ref.watch(selectedRecapDateProvider);
  final dateStr = DateFormat('yyyy-MM-dd').format(date);
  final attendanceAsync = ref.watch(dailyAttendanceStreamProvider(dateStr));
  
  // 3. Ambil query pencarian
  final searchQuery = ref.watch(recapSearchProvider).toLowerCase();

  // Gabungkan status loading/error dari kedua sumber data
  return employeesAsync.when(
    data: (employees) {
      return attendanceAsync.when(
        data: (attendances) {
          final List<RecapItem> recapList = [];

          for (var emp in employees) {
            final matchesSearch = emp.name.toLowerCase().contains(searchQuery) ||
                                emp.employeeId.toLowerCase().contains(searchQuery);
            
            if (!matchesSearch) continue;

            final att = attendances.where((a) => a.uid == emp.id).firstOrNull;
            recapList.add(RecapItem(employee: emp, attendance: att));
          }
          return AsyncValue.data(recapList);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
