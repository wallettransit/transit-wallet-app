import 'package:supabase_flutter/supabase_flutter.dart';

class EmailOtpService {
  static final _supabase = Supabase.instance.client;

  /// Sends a 4-digit OTP to the given [email] using our Edge Function.
  /// Returns a mock `pinId` which is required for verification.
  static Future<String> sendOtp(String email) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email-otp',
        body: {'email': email},
      );
      
      final data = response.data;
      
      if (data['success'] == true) {
        // For development, we return the generated pinId (and theoretically we'd just use '1234' on the client)
        return data['pinId'] ?? 'email_otp_dev';
      } else {
        throw Exception(data['error'] ?? 'Failed to send Email OTP');
      }
    } catch (e) {
      throw Exception('Error calling email OTP service: $e');
    }
  }

  /// Verifies the OTP using the [pinId] and the [pin] entered by the user.
  /// In this mock implementation, it accepts "1234" for development purposes.
  static Future<bool> verifyOtp(String pinId, String pin) async {
    // In a production app, we would call another Edge Function to verify the hash.
    // For now, since we're using this as a dummy bypass, we accept 1234.
    if (pin == '1234') {
      return true;
    } else {
      throw Exception('Invalid OTP code. Please use 1234 for testing.');
    }
  }
}
