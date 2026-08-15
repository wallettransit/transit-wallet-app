import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final networkStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final offlineStateProvider = Provider<bool>((ref) {
  final status = ref.watch(networkStatusProvider).valueOrNull;
  if (status == null) return false;
  return status.contains(ConnectivityResult.none) && status.length == 1;
});
