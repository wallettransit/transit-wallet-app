import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scan_repository.dart';

final scanControllerProvider = StateNotifierProvider<ScanController, AsyncValue<Map<String, dynamic>?>>((ref) {
  return ScanController(ref.read(scanRepositoryProvider));
});

class ScanController extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final ScanRepository _repository;

  ScanController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> processQrCode(String payload) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.scanDriverQr(payload);
      state = AsyncValue.data(data);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> payForRide({
    required String passengerId,
    required String driverId,
    required String routeId,
    required String fareTierId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.payForRide(
        passengerId: passengerId,
        driverId: driverId,
        routeId: routeId,
        fareTierId: fareTierId,
      );
      // Wait, we don't want to overwrite the ride data in the state unless we specifically need it
      // Let's just return true.
      state = AsyncValue.data(state.value); 
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
