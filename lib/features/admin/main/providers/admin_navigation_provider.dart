import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminMenu {
  dashboard,
  tinjauLaporan,
  aktivasiStaf,
  dataKaryawan,
  rekapAbsensi,
}

final adminNavigationProvider = StateProvider<AdminMenu>((ref) {
  return AdminMenu.dashboard;
});
