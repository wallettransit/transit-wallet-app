import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'core/providers/network_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/session_manager.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/wallet/presentation/passenger_main_layout.dart';
import 'features/auth/presentation/app_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }

  try {
    await Supabase.initialize(
      url: 'https://shoehdyteenfeofqmsko.supabase.co',
      anonKey: 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc',
    );
  } catch (e) {
    debugPrint("Failed to initialize Supabase: $e");
  }

  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Failed to initialize Firebase: $e");
  }
  
  // Make the app full screen (edge-to-edge)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  
  runApp(
    ProviderScope(
      child: TransitWalletApp(key: UniqueKey()),
    ),
  );
}

class TransitWalletApp extends ConsumerStatefulWidget {
  const TransitWalletApp({super.key});

  @override
  ConsumerState<TransitWalletApp> createState() => _TransitWalletAppState();
}

class _TransitWalletAppState extends ConsumerState<TransitWalletApp> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OyaPay',
      theme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const _AuthWrapper(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: SessionManager(
            child: Stack(
              children: [
                _OfflineBannerWrapper(child: child!),
                const _LockScreenOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LockScreenOverlay extends ConsumerWidget {
  const _LockScreenOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show lock screen if app is locked AND user is actually authenticated
    final isLocked = ref.watch(isAppLockedProvider);
    final authState = ref.watch(authStateChangesProvider).value;
    final isAuthenticated = authState?.session != null;

    if (isLocked && isAuthenticated) {
      return const Positioned.fill(
        child: AppLockScreen(),
      );
    }
    return const SizedBox.shrink();
  }
}

class _AuthWrapper extends ConsumerStatefulWidget {
  const _AuthWrapper();

  @override
  ConsumerState<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<_AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Small delay to allow providers to mount
    await Future.delayed(Duration.zero);
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && mounted) {
      // User is logged in, navigate to main layout
      // Note: role-based routing can be added here if we have drivers
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PassengerMainLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}

class _OfflineBannerWrapper extends ConsumerWidget {
  final Widget child;
  const _OfflineBannerWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineStateProvider);
    
    return Stack(
      children: [
        child,
        if (isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                color: AppColors.danfoYellow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.ink, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Low Connectivity - Offline Mode Active',
                      style: GoogleFonts.manrope(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none, // Need this since it's above MaterialApp navigator
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5)),
            ),
          ).animate().slideY(begin: -1.0, end: 0, curve: Curves.easeOutBack, duration: 400.ms),
      ],
    );
  }
}

