import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'secure_storage_service.dart';

class SessionManager extends ConsumerStatefulWidget {
  final Widget child;

  const SessionManager({super.key, required this.child});

  @override
  ConsumerState<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends ConsumerState<SessionManager> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  static const String _lastActiveKey = 'last_active_timestamp';
  Duration _timeoutDuration = const Duration(minutes: 5); // default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTimeoutAndCheck();
  }

  Future<void> _loadTimeoutAndCheck() async {
    final timeoutSeconds = await SecureStorageService.getLockTimeoutSeconds();
    _timeoutDuration = Duration(seconds: timeoutSeconds);
    await _checkBackgroundTimeout();
    _startTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startTimer() {
    _inactivityTimer?.cancel();
    final authState = ref.read(authStateChangesProvider).value;
    if (authState?.session != null && !ref.read(isAppLockedProvider)) {
      // Never lock if timeout is set to 0 (meaning "never")
      if (_timeoutDuration.inSeconds > 0) {
        _inactivityTimer = Timer(_timeoutDuration, _handleTimeout);
      }
    }
  }

  void _resetTimer() {
    _recordActiveTimestamp();
    _startTimer();
  }

  Future<void> _handleTimeout() async {
    final authState = ref.read(authStateChangesProvider).value;
    if (authState?.session != null) {
      final deviceLockEnabled = await SecureStorageService.isDeviceLockEnabled();
      final hasPin = await SecureStorageService.hasPin();
      if (deviceLockEnabled && hasPin) {
        ref.read(isAppLockedProvider.notifier).state = true;
      }
    }
  }

  Future<void> _recordActiveTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _checkBackgroundTimeout() async {
    final deviceLockEnabled = await SecureStorageService.isDeviceLockEnabled();
    final hasPin = await SecureStorageService.hasPin();
    if (!deviceLockEnabled || !hasPin) return;

    final prefs = await SharedPreferences.getInstance();
    final lastActiveMillis = prefs.getInt(_lastActiveKey);

    if (lastActiveMillis != null) {
      final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
      final difference = DateTime.now().difference(lastActive);

      if (difference > _timeoutDuration && _timeoutDuration.inSeconds > 0) {
        Future.microtask(() {
          final authState = ref.read(authStateChangesProvider).value;
          if (authState?.session != null) {
            ref.read(isAppLockedProvider.notifier).state = true;
          }
        });
      }
    }
    _recordActiveTimestamp();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTimeoutAndCheck(); // Reload timeout in case user changed it
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _inactivityTimer?.cancel();
      _recordActiveTimestamp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      onScaleStart: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
