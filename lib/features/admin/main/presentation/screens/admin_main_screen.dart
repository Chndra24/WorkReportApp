import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/features/auth/presentation/providers/auth_provider.dart';
import 'package:workreport/features/auth/presentation/screens/auth_screen.dart';
import '../pages/dashboard_page.dart';
import 'package:workreport/features/admin/activation/presentation/pages/staff_activation_page.dart';
import 'package:workreport/features/admin/main/providers/admin_navigation_provider.dart';
import 'package:workreport/features/admin/employee/presentation/pages/employee_page.dart';
import 'package:workreport/features/admin/recap/presentation/pages/attendance_recap_page.dart';
import 'package:workreport/features/admin/review/presentation/pages/review_report_page.dart';

class AdminMainScreen extends ConsumerWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenu = ref.watch(adminNavigationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(selectedMenu),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(),
      body: _getBody(selectedMenu),
    );
  }

  String _getAppBarTitle(AdminMenu menu) {
    switch (menu) {
      case AdminMenu.dashboard:
        return 'Dashboard Admin';
      case AdminMenu.tinjauLaporan:
        return 'Tinjau Laporan';
      case AdminMenu.aktivasiStaf:
        return 'Aktivasi Staf';
      case AdminMenu.dataKaryawan:
        return 'Data Karyawan';
      case AdminMenu.rekapAbsensi:
        return 'Rekap Absensi';
    }
  }

  Widget _getBody(AdminMenu menu) {
    switch (menu) {
      case AdminMenu.dashboard:
        return const DashboardPage();
      case AdminMenu.tinjauLaporan:
        return const ReviewReportPage();
      case AdminMenu.aktivasiStaf:
        return const StaffActivationPage();
      case AdminMenu.dataKaryawan:
        return const EmployeePage();
      case AdminMenu.rekapAbsensi:
        return const AttendanceRecapPage();
    }
  }
}

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenu = ref.watch(adminNavigationProvider);
    final user = ref.watch(authProvider).user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            accountName: Text(user?.name ?? "Administrator"),
            accountEmail: Text(user?.email ?? "admin@office.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.indigo, size: 40),
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected: selectedMenu == AdminMenu.dashboard,
            onTap: () => _selectMenu(ref, context, AdminMenu.dashboard),
          ),
          _DrawerItem(
            icon: Icons.rate_review_outlined,
            label: 'Tinjau Laporan',
            isSelected: selectedMenu == AdminMenu.tinjauLaporan,
            onTap: () => _selectMenu(ref, context, AdminMenu.tinjauLaporan),
          ),
          _DrawerItem(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Aktivasi Staf',
            isSelected: selectedMenu == AdminMenu.aktivasiStaf,
            onTap: () => _selectMenu(ref, context, AdminMenu.aktivasiStaf),
          ),
          _DrawerItem(
            icon: Icons.badge_outlined,
            label: 'Data Karyawan',
            isSelected: selectedMenu == AdminMenu.dataKaryawan,
            onTap: () => _selectMenu(ref, context, AdminMenu.dataKaryawan),
          ),
          _DrawerItem(
            icon: Icons.analytics_outlined,
            label: 'Rekap Absensi',
            isSelected: selectedMenu == AdminMenu.rekapAbsensi,
            onTap: () => _selectMenu(ref, context, AdminMenu.rekapAbsensi),
          ),
          const Spacer(),
          const Divider(),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Logout',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () async {
              final confirm = await _showLogoutDialog(context);
              if (confirm == true) {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _selectMenu(WidgetRef ref, BuildContext context, AdminMenu menu) {
    ref.read(adminNavigationProvider.notifier).state = menu;
    Navigator.pop(context);
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : iconColor),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
