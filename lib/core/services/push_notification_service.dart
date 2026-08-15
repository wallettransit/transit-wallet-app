import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

class PushNotificationService {
  final _supabase = Supabase.instance.client;

  /// Call this when the app starts. It will request permission and save the FCM token to Supabase.
  Future<void> initialize() async {
    // Ensure Firebase is initialized before proceeding
    if (Firebase.apps.isEmpty) {
      print('Firebase is not initialized. Skipping push notification setup.');
      return;
    }

    // 1. Request permissions (especially for iOS)
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Get the token
      String? token = await messaging.getToken();
      
      // 3. Save to Supabase
      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      // 4. Listen for token refreshes
      messaging.onTokenRefresh.listen(_saveTokenToSupabase);
      
      // 5. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      });
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('users').update({'fcm_token': token}).eq('id', user.id);
      } catch (e) {
        print('Failed to save FCM token: $e');
      }
    }
  }
}
