enum AttendanceStatus { tepatWaktu, terlambat, menunggu }

class AttendanceModel {
  final String uid;           // UID Document dari collection users
  final String employeeId;    // employeeId dari collection users
  final String dateStr;       // "YYYY-MM-DD" untuk identifikasi harian
  final DateTime? clockIn;    // Disimpan sebagai Timestamp di Firestore
  final DateTime? clockOut;   // Disimpan sebagai Timestamp di Firestore
  final AttendanceStatus status;

  AttendanceModel({
    required this.uid,
    required this.employeeId,
    required this.dateStr,
    this.clockIn,
    this.clockOut,
    required this.status,
  });

  // Logika penentuan status saat Absen Masuk
  static AttendanceStatus calculateStatus(DateTime timeIn) {
    if (timeIn.hour < 8 || (timeIn.hour == 8 && timeIn.minute <= 30)) {
      return AttendanceStatus.tepatWaktu;
    } else {
      return AttendanceStatus.terlambat;
    }
  }
}
