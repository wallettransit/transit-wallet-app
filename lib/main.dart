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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://shoehdyteenfeofqmsko.supabase.co',
      anonKey: 'sb_publishable_I9jMQGv0GXQL7j8GEDFsAg_JJTVJxzc',
    );
  } catch (e) {
    debugPrint("Failed to initialize Supabase: $e");
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

class TransitWalletApp extends StatelessWidget {
  const TransitWalletApp({super.key});

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
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: _OfflineBannerWrapper(child: child!),
        );
      },
    );
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

