import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static const _keyEmail = 'biometric_email';
  static const _keyPassword = 'biometric_password';
  static const _keyBiometricEnabled = 'biometric_enabled';

  static const _keyPin = 'app_pin';

  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyBiometricEnabled, value: 'true');
  }

  // --- PIN Methods ---
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _keyPin, value: pin);
  }

  static Future<String?> getPin() async {
    return await _storage.read(key: _keyPin);
  }
  
  static Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }
  // -------------------

  static Future<Map<String, String>?> getCredentials() async {
    final enabled = await _storage.read(key: _keyBiometricEnabled);
    if (enabled != 'true') return null;

    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyBiometricEnabled);
    await _storage.delete(key: _keyPin);
  }
}
