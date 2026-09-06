import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/employee/main/presentation/providers/employee_navigation_provider.dart';
import 'package:workreport/features/employee/main/presentation/widgets/employee_drawer.dart';
import 'package:workreport/features/employee/dashboard/presentation/pages/employee_dashboard_page.dart';
import 'package:workreport/features/employee/attendance/presentation/pages/attendance_page.dart';
import 'package:workreport/features/employee/reports/presentation/pages/create_report_page.dart';
import 'package:workreport/features/employee/history/presentation/pages/report_history_page.dart';

class EmployeeMainScreen extends ConsumerWidget {
  const EmployeeMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenu = ref.watch(employeeNavigationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(selectedMenu),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const EmployeeDrawer(),
      body: _getBody(selectedMenu),
    );
  }

  String _getAppBarTitle(EmployeeMenu menu) {
    switch (menu) {
      case EmployeeMenu.dashboard:
        return 'Dashboard Karyawan';
      case EmployeeMenu.presensi:
        return 'Presensi';
      case EmployeeMenu.buatLaporan:
        return 'Buat Laporan';
      case EmployeeMenu.riwayatKerja:
        return 'Riwayat Kerja';
    }
  }

  Widget _getBody(EmployeeMenu menu) {
    switch (menu) {
      case EmployeeMenu.dashboard:
        return const EmployeeDashboardPage();
      case EmployeeMenu.presensi:
        return const AttendancePage();
      case EmployeeMenu.buatLaporan:
        return const CreateReportPage();
      case EmployeeMenu.riwayatKerja:
        return const ReportHistoryPage();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Halaman ${_getAppBarTitle(menu)}\nsedang dalam pengembangan',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
    }
  }
}
