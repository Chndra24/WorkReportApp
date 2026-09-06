import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/user_model.dart';

final employeeRepositoryProvider = Provider((ref) {
  return EmployeeRepository(FirebaseFirestore.instance);
});

class EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepository(this._firestore);

  /// Menonton daftar karyawan yang sudah diverifikasi secara real-time
  Stream<List<UserData>> watchVerifiedEmployees() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.karyawan.name)
        .where('isVerified', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserData.fromJson(doc.data()))
            .toList());
  }

  /// Memperbarui status karyawan
  Future<void> updateEmployeeStatus(String uid, UserStatus status) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Gagal memperbarui status: $e');
    }
  }
}
