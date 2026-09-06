import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/screens/auth_screen.dart';
import '../providers/employee_navigation_provider.dart';

class EmployeeDrawer extends ConsumerWidget {
  const EmployeeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenu = ref.watch(employeeNavigationProvider);
    final user = ref.watch(authProvider).user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            accountName: Text(user?.name ?? "Karyawan"),
            accountEmail: Text(user?.email ?? "employee@office.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "E",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
          ),
          _drawerItem(
            ref,
            context,
            Icons.dashboard_outlined,
            "Dashboard",
            EmployeeMenu.dashboard,
            selectedMenu == EmployeeMenu.dashboard,
          ),
          _drawerItem(
            ref,
            context,
            Icons.timer_outlined,
            "Presensi",
            EmployeeMenu.presensi,
            selectedMenu == EmployeeMenu.presensi,
          ),
          _drawerItem(
            ref,
            context,
            Icons.post_add_outlined,
            "Buat Laporan",
            EmployeeMenu.buatLaporan,
            selectedMenu == EmployeeMenu.buatLaporan,
          ),
          _drawerItem(
            ref,
            context,
            Icons.history_outlined,
            "Riwayat Kerja",
            EmployeeMenu.riwayatKerja,
            selectedMenu == EmployeeMenu.riwayatKerja,
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
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

  Widget _drawerItem(
    WidgetRef ref,
    BuildContext context,
    IconData icon,
    String label,
    EmployeeMenu menu,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.indigo : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        ref.read(employeeNavigationProvider.notifier).state = menu;
        Navigator.pop(context);
      },
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
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
