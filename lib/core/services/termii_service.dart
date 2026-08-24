import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TermiiService {
  static const String _baseUrl = 'https://api.ng.termii.com/api';

  static String get _apiKey {
    final key = dotenv.env['TERMII_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('TERMII_API_KEY is not set in .env');
    }
    return key;
  }

  static String get _senderId {
    return dotenv.env['TERMII_SENDER_ID'] ?? 'N-Alert';
  }

  /// Sends a 4-digit OTP to the given [phoneNumber].
  /// Returns the `pinId` which is required for verification.
  static Future<String> sendOtp(String phoneNumber) async {
    // Termii expects numbers in format '2348012345678' (no '+', starts with country code)
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '234${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('234')) {
      cleanPhone = '234$cleanPhone';
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/sms/otp/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "api_key": _apiKey,
        "message_type": "NUMERIC",
        "to": cleanPhone,
        "from": _senderId,
        "channel": "dnd",
        "pin_attempts": 10,
        "pin_time_to_live": 5,
        "pin_length": 4,
        "pin_placeholder": "< 1234 >",
        "message_text": "Your OyaPayWallet verification code is < 1234 >. Valid for 5 minutes.",
        "pin_type": "NUMERIC"
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['pinId'] != null) {
      return data['pinId'];
    } else {
      throw Exception(data['message'] ?? 'Failed to send OTP');
    }
  }

  /// Verifies the OTP using the [pinId] and the [pin] entered by the user.
  static Future<bool> verifyOtp(String pinId, String pin) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sms/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "api_key": _apiKey,
        "pin_id": pinId,
        "pin": pin,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['verified'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Invalid OTP code');
    }
  }
}
