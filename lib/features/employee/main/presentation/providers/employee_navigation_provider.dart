import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EmployeeMenu { dashboard, presensi, buatLaporan, riwayatKerja }

final employeeNavigationProvider = StateProvider<EmployeeMenu>((ref) => EmployeeMenu.dashboard);
