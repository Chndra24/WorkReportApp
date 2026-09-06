import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/attendance_repository.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../../core/models/attendance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider untuk jam real-time
final realTimeClockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// Provider untuk memantau status absen hari ini dari Firestore
final todayAttendanceProvider = StreamProvider<AttendanceModel?>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return Stream.value(null);

  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  return ref.watch(attendanceRepositoryProvider)
      .watchUserAttendance(user.id, todayStr)
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data() as Map<String, dynamic>;
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
      });
});

/// Provider untuk riwayat absen user
final attendanceHistoryStreamProvider = StreamProvider<List<AttendanceModel>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return Stream.value([]);
  
  return ref.watch(attendanceRepositoryProvider).watchAttendanceHistory(user.id);
});
