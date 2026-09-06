import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/attendance_model.dart';

final recapRepositoryProvider = Provider((ref) => RecapRepository(FirebaseFirestore.instance));

class RecapRepository {
  final FirebaseFirestore _firestore;
  RecapRepository(this._firestore);

  /// Mengambil semua data absensi pada tanggal tertentu (dateStr: YYYY-MM-DD)
  Stream<List<AttendanceModel>> watchAllAttendanceByDate(String dateStr) {
    return _firestore
        .collection('attendance')
        .where('dateStr', isEqualTo: dateStr)
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
}
