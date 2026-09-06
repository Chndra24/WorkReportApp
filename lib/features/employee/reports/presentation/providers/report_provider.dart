import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/work_report_model.dart';
import 'package:workreport/features/auth/presentation/providers/auth_provider.dart';

class ReportState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ReportState({this.isLoading = false, this.error, this.isSuccess = false});
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref);
});

class ReportNotifier extends StateNotifier<ReportState> {
  final Ref _ref;
  ReportNotifier(this._ref) : super(ReportState());

  // KONFIGURASI CLOUDINARY
  final String _cloudName = "icqgqvvl";
  final String _uploadPreset = "ml_default";

  Future<void> submitReport({
    required DateTime date,
    required String title,
    required String location,
    required String description,
    required File imageFile,
  }) async {
    state = ReportState(isLoading: true);

    try {
      final user = _ref.read(authProvider).user;
      if (user == null) throw Exception("User tidak ditemukan");

      // 1. Upload ke Cloudinary
      final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
      final CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'work_reports'),
      );

      // 2. Simpan ke Firestore
      final docRef = FirebaseFirestore.instance.collection('work_reports').doc();
      final report = WorkReportModel(
        id: docRef.id,
        uid: user.id,
        employeeName: user.name,
        employeeId: user.employeeId, // Field yang sebelumnya menyebabkan error
        date: date,
        createdAt: DateTime.now(),
        title: title,
        location: location,
        description: description,
        imageUrl: response.secureUrl,
        status: ReportStatus.waiting,
      );

      await docRef.set(report.toJson());
      state = ReportState(isSuccess: true);
    } catch (e) {
      state = ReportState(error: e.toString());
    }
  }
}
