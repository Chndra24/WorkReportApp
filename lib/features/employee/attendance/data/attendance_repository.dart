import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/attendance_model.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository(FirebaseFirestore.instance));

class AttendanceRepository {
  final FirebaseFirestore _firestore;
  AttendanceRepository(this._firestore);

  /// Mengambil data absen user untuk hari tertentu (Real-time)
  Stream<DocumentSnapshot> watchUserAttendance(String uid, String dateStr) {
    return _firestore.collection('attendance').doc('${uid}_$dateStr').snapshots();
  }

  /// Mengambil riwayat absen user (10 terakhir di bulan ini)
  Stream<List<AttendanceModel>> watchAttendanceHistory(String uid) {
    final now = DateTime.now();
    // Mendapatkan Timestamp awal bulan ini (Tanggal 1 jam 00:00)
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _firestore
        .collection('attendance')
        .where('uid', isEqualTo: uid)
        .where('clockIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .orderBy('clockIn', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return AttendanceModel(
                uid: data['uid'],
                employeeId: data['employeeId'],
                dateStr: data['dateStr'],
                clockIn: (data['clockIn'] as Timestamp?)?.toDate(),
                clockOut: (data['clockOut'] as Timestamp?)?.toDate(),
                status: AttendanceStatus.values.firstWhere(
                  (e) => e.name == data['status'],
                  orElse: () => AttendanceStatus.menunggu,
                ),
              );
            }).toList());
  }

  /// Fungsi Absen Masuk
  Future<void> checkIn(AttendanceModel attendance) async {
    try {
      final docId = '${attendance.uid}_${attendance.dateStr}';
      await _firestore.collection('attendance').doc(docId).set({
        'uid': attendance.uid,
        'employeeId': attendance.employeeId,
        'dateStr': attendance.dateStr,
        'clockIn': attendance.clockIn != null ? Timestamp.fromDate(attendance.clockIn!) : null,
        'clockOut': null,
        'status': attendance.status.name,
      });
    } catch (e) {
      throw Exception('Gagal Absen Masuk: $e');
    }
  }

  /// Fungsi Absen Keluar
  Future<void> checkOut(String uid, String dateStr, DateTime timeOut) async {
    try {
      final docId = '${uid}_$dateStr';
      await _firestore.collection('attendance').doc(docId).update({
        'clockOut': Timestamp.fromDate(timeOut),
      });
    } catch (e) {
      throw Exception('Gagal Absen Keluar: $e');
    }
  }
}
