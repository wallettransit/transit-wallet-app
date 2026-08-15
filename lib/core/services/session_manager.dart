import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/providers/auth_provider.dart';

class SessionManager extends ConsumerStatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionManager({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  ConsumerState<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends ConsumerState<SessionManager> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  static const String _lastActiveKey = 'last_active_timestamp';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBackgroundTimeout();
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
    // Only run timer if user is authenticated
    final authState = ref.read(authStateChangesProvider).value;
    if (authState?.session != null && !ref.read(isAppLockedProvider)) {
      _inactivityTimer = Timer(widget.timeoutDuration, _handleTimeout);
    }
  }

  void _resetTimer() {
    _recordActiveTimestamp();
    _startTimer();
  }

  void _handleTimeout() {
    // Lock the app
    ref.read(isAppLockedProvider.notifier).state = true;
  }

  Future<void> _recordActiveTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _checkBackgroundTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMillis = prefs.getInt(_lastActiveKey);
    
    if (lastActiveMillis != null) {
      final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMillis);
      final difference = DateTime.now().difference(lastActive);
      
      if (difference > widget.timeoutDuration) {
        // We've been in the background/killed for too long, lock on startup
        // Delay to allow providers to initialize
        Future.microtask(() {
          ref.read(isAppLockedProvider.notifier).state = true;
        });
      }
    }
    _recordActiveTimestamp();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBackgroundTimeout();
      _startTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _inactivityTimer?.cancel();
      _recordActiveTimestamp();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with GestureDetector to catch all interactions
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer,
      onScaleStart: (_) => _resetTimer,
      child: widget.child,
    );
  }
}
