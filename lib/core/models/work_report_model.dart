import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { waiting, approved, rejected }

class WorkReportModel {
  final String id;
  final String uid;
  final String employeeName;
  final String employeeId; // Field tambahan untuk ID unik karyawan (misal: KRY-001)
  final DateTime date;
  final DateTime createdAt;
  final String title;
  final String location;
  final String description;
  final String imageUrl;
  final ReportStatus status;

  const WorkReportModel({
    required this.id,
    required this.uid,
    required this.employeeName,
    required this.employeeId,
    required this.date,
    required this.createdAt,
    required this.title,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'title': title,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'status': status.name,
    };
  }

  factory WorkReportModel.fromJson(Map<String, dynamic> json) {
    return WorkReportModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      employeeName: json['employeeName'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.waiting,
      ),
    );
  }
}
