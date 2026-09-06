import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/user_model.dart';

final staffActivationRepositoryProvider = Provider((ref) {
  return StaffActivationRepository(FirebaseFirestore.instance);
});

class StaffActivationRepository {
  final FirebaseFirestore _firestore;

  StaffActivationRepository(this._firestore);

  /// Mengambil stream daftar staf yang belum diverifikasi (Real-time)
  Stream<List<UserData>> watchPendingActivationStaff() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.karyawan.name)
        .where('isVerified', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserData.fromJson(doc.data()))
            .toList());
  }

  /// Mengambil daftar staf (untuk refresh manual jika dibutuhkan)
  Future<List<UserData>> getPendingActivationStaff() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.karyawan.name)
          .where('isVerified', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => UserData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data staf: $e');
    }
  }

  /// Menyetujui aktivasi staf
  Future<void> approveStaff(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isVerified': true,
      });
    } catch (e) {
      throw Exception('Gagal menyetujui staf: $e');
    }
  }

  /// Menolak aktivasi staf (menghapus data atau menandai sebagai ditolak)
  /// Dalam spesifikasi ini, kita hapus agar tidak menumpuk di list aktivasi
  Future<void> rejectStaff(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Gagal menolak staf: $e');
    }
  }
}
