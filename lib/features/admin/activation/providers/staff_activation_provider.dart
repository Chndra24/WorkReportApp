import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workreport/core/models/user_model.dart';
import '../data/staff_activation_repository.dart';

/// Provider untuk Stream data staf
final staffActivationStreamProvider = StreamProvider<List<UserData>>((ref) {
  final repository = ref.watch(staffActivationRepositoryProvider);
  return repository.watchPendingActivationStaff();
});

/// Provider untuk Aksi (Approve/Reject)
final staffActivationActionProvider = Provider((ref) {
  return StaffActivationActionNotifier(ref);
});

class StaffActivationActionNotifier {
  final Ref _ref;
  StaffActivationActionNotifier(this._ref);

  Future<void> approve(String uid) async {
    await _ref.read(staffActivationRepositoryProvider).approveStaff(uid);
  }

  Future<void> reject(String uid) async {
    await _ref.read(staffActivationRepositoryProvider).rejectStaff(uid);
  }
}
