import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/work_report_model.dart';

final workReportRepositoryProvider = Provider((ref) => WorkReportRepository(FirebaseFirestore.instance));

class WorkReportRepository {
  final FirebaseFirestore _firestore;
  WorkReportRepository(this._firestore);

  /// Menonton daftar laporan kerja milik user tertentu (Real-time)
  Stream<List<WorkReportModel>> watchUserReports(String uid) {
    return _firestore
        .collection('work_reports')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return WorkReportModel.fromJson(doc.data());
            }).toList());
  }

  /// Menonton seluruh daftar laporan kerja (untuk Admin)
  Stream<List<WorkReportModel>> watchAllReports() {
    return _firestore
        .collection('work_reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return WorkReportModel.fromJson(doc.data());
            }).toList());
  }

  /// Memperbarui status laporan kerja
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      await _firestore.collection('work_reports').doc(reportId).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Gagal memperbarui status laporan: $e');
    }
  }
}
