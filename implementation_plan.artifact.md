# Implementasi Halaman Data Karyawan (Admin)

Saya akan mengimplementasikan halaman "Data Karyawan" sesuai dengan spesifikasi yang diberikan, mengikuti standar `AGENTS.md` dan mengintegrasikannya dengan Firestore.

## User Review Required
> [!IMPORTANT]
> Saya akan memperbarui `UserData` model untuk menyertakan enum `UserStatus` (Aktif, Cuti, Non-Aktif) agar sesuai dengan kebutuhan UI. Pastikan data di Firestore nantinya memiliki field `status` yang sesuai dengan nama enum ini.

## Proposed Changes

### Core & Data Layer
#### [MODIFY] [user_model.dart](file:///D:/CHANDRA/Android Project/workreport/lib/core/models/user_model.dart)
- Menambahkan enum `UserStatus`.
- Menambahkan field `status` ke kelas `UserData`.
- Memperbarui `fromJson`, `toJson`, dan `copyWith`.

#### [NEW] [employee_repository.dart](file:///D:/CHANDRA/Android Project/workreport/lib/features/admin/employee/data/employee_repository.dart)
- Menambahkan repository untuk mengambil data seluruh karyawan dari Firestore.

### Logic & State Management (Riverpod)
#### [NEW] [employee_provider.dart](file:///D:/CHANDRA/Android Project/workreport/lib/features/admin/employee/presentation/providers/employee_provider.dart)
- `employeeListProvider`: Menonton stream data karyawan dari repository.
- `employeeSearchProvider`: Mengelola query pencarian.
- `filteredEmployeesProvider`: Menggabungkan data karyawan dengan filter pencarian.

### UI Layer
#### [NEW] [employee_list_screen.dart](file:///D:/CHANDRA/Android Project/workreport/lib/features/admin/employee/presentation/screens/employee_list_screen.dart)
- Halaman utama daftar karyawan dengan Search Bar.

#### [NEW] [employee_tile_widget.dart](file:///D:/CHANDRA/Android Project/workreport/lib/features/admin/employee/presentation/widgets/employee_tile_widget.dart)
- Komponen kartu karyawan yang responsif.

#### [NEW] [employee_detail_sheet.dart](file:///D:/CHANDRA/Android Project/workreport/lib/features/admin/employee/presentation/widgets/employee_detail_sheet.dart)
- ModalBottomSheet untuk menampilkan detail singkat karyawan.

#### [MODIFY] [admin_drawer.dart](file:///D:/CHANDRA/Android Project/workreport/lib/features/admin/presentation/widgets/admin_drawer.dart)
- Menghubungkan menu "Data Karyawan" ke halaman yang baru dibuat.

## Verification Plan

### Automated Tests
- Menjalankan aplikasi untuk memastikan data dari Firestore muncul di list.
- Mencoba fitur pencarian berdasarkan Nama dan ID.

### Manual Verification
- Memastikan orientasi tetap Portrait (menggunakan `SystemChrome`).
- Memastikan navigasi Drawer berfungsi.
- Memastikan badge status memiliki warna yang benar.
