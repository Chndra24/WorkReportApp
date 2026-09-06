# Implementasi Halaman Aktivasi Staf (Admin)

Membangun fitur aktivasi karyawan untuk hak akses Admin menggunakan Riverpod dan Firestore. Fitur ini mencakup sistem navigasi berbasis State (Drawer) dan manajemen data staf yang belum terverifikasi.

## User Review Required

> [!IMPORTANT]
> Pastikan koleksi di Firestore bernama `users` dan memiliki indeks yang sesuai jika diperlukan (walaupun filter sederhana `where` biasanya tidak butuh indeks manual untuk query kecil).

> [!NOTE]
> Navigasi menggunakan `StateProvider` sederhana untuk mengelola konten `body` di `AdminMainScreen`. Jika Anda berencana menggunakan `go_router` secara mendalam di masa depan, sistem ini tetap mudah diadaptasi.

## Proposed Changes

### [Admin Features] - Activation & Navigation

#### [NEW] [staff_activation_repository.dart](file:///D:/CHANDRA/Android%20Project/workreport/lib/features/admin/activation/data/staff_activation_repository.dart)
Menangani fetch data `users` dengan filter `isVerified == false` dan `role == karyawan`, serta fungsi update status verifikasi.

#### [NEW] [staff_activation_provider.dart](file:///D:/CHANDRA/Android%20Project/workreport/lib/features/admin/activation/providers/staff_activation_provider.dart)
Mengelola state list staf menggunakan `AsyncNotifierProvider` untuk penanganan loading, success, dan error secara otomatis.

#### [NEW] [admin_navigation_provider.dart](file:///D:/CHANDRA/Android%20Project/workreport/lib/features/admin/main/providers/admin_navigation_provider.dart)
Mengelola state menu aktif pada Navigation Drawer.

#### [NEW] [admin_main_screen.dart](file:///D:/CHANDRA/Android%20Project/workreport/lib/features/admin/main/presentation/screens/admin_main_screen.dart)
Scaffold utama yang berisi `AppBar`, `Drawer`, dan penentuan `body` berdasarkan menu yang dipilih.

#### [NEW] [staff_activation_page.dart](file:///D:/CHANDRA/Android%20Project/workreport/lib/features/admin/activation/presentation/pages/staff_activation_page.dart)
Halaman utama daftar aktivasi dengan `RefreshIndicator` dan `Empty State`.

#### [NEW] [staff_activation_card.dart](file:///D:/CHANDRA/Android%20Project/workreport/lib/features/admin/activation/presentation/widgets/staff_activation_card.dart)
Komponen kartu responsif untuk setiap item staf, lengkap dengan dialog konfirmasi.

## Verification Plan

### Manual Verification
1. Buka halaman Admin Main Screen.
2. Pastikan Drawer muncul dan menu "Aktivasi Staf" dapat diklik.
3. Verifikasi daftar staf muncul jika ada data di Firestore dengan `isVerified: false`.
4. Uji tombol "Setujui": Pastikan muncul Dialog Konfirmasi, data terupdate di Firebase, dan daftar di UI otomatis terhapus (karena sudah verified).
5. Uji tombol "Tolak": Pastikan muncul Dialog Konfirmasi dan data dihapus dari Firebase (atau opsi lain jika ingin tetap ada namun ditolak).
6. Uji Empty State dengan menghapus/memverifikasi semua data.
