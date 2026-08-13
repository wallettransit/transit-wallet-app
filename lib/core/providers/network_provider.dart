import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A global provider to mock the offline state of the application.
/// In a real application, this would listen to connectivity_plus.
final offlineStateProvider = StateProvider<bool>((ref) => false);
