import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized secure storage service.
/// PIN is stored as a SHA-256 hash — never in plaintext.
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // --- Keys ---
  static const _keyEmail = 'biometric_email';
  static const _keyPassword = 'biometric_password';
  static const _keyBiometricEnabled = 'biometric_enabled';
  static const _keyPin = 'app_pin_hash'; // Now stores SHA-256 hash
  static const _keyTransactionPin = 'transaction_pin_hash';

  // SharedPreferences keys (non-sensitive, fast access)
  static const _keyLockTimeoutSeconds = 'lock_timeout_seconds';
  static const _keyDeviceLockEnabled = 'device_lock_enabled';
  static const _keyBiometricUnlockEnabled = 'biometric_unlock_enabled';

  // Lockout keys (stored in secure storage)
  static const _keyPinFailedAttempts = 'pin_failed_attempts';
  static const _keyPinLockoutUntil = 'pin_lockout_until_millis';
  static const _keyTransactionPinFailedAttempts = 'txn_pin_failed_attempts';
  static const _keyTransactionPinLockoutUntil = 'txn_pin_lockout_until_millis';

  // -------------------------------------------------------------------------
  // Hashing
  // -------------------------------------------------------------------------
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // -------------------------------------------------------------------------
  // App Unlock PIN
  // -------------------------------------------------------------------------
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _keyPin, value: _hashPin(pin));
    // Reset failed attempts on new PIN creation
    await _storage.write(key: _keyPinFailedAttempts, value: '0');
    await _storage.delete(key: _keyPinLockoutUntil);
  }

  static Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPin);
    return hash != null && hash.isNotEmpty;
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _keyPin);
    if (storedHash == null) return false;
    return _hashPin(pin) == storedHash;
  }

  // -------------------------------------------------------------------------
  // Transaction PIN
  // -------------------------------------------------------------------------
  static Future<void> saveTransactionPin(String pin) async {
    await _storage.write(key: _keyTransactionPin, value: _hashPin(pin));
    await _storage.write(key: _keyTransactionPinFailedAttempts, value: '0');
    await _storage.delete(key: _keyTransactionPinLockoutUntil);
  }

  static Future<bool> hasTransactionPin() async {
    final hash = await _storage.read(key: _keyTransactionPin);
    return hash != null && hash.isNotEmpty;
  }

  static Future<bool> verifyTransactionPin(String pin) async {
    final storedHash = await _storage.read(key: _keyTransactionPin);
    if (storedHash == null) return false;
    return _hashPin(pin) == storedHash;
  }

  // -------------------------------------------------------------------------
  // PIN Lockout Logic (App Lock PIN)
  // -------------------------------------------------------------------------

  /// Returns the number of failed unlock attempts since last success.
  static Future<int> getPinFailedAttempts() async {
    final val = await _storage.read(key: _keyPinFailedAttempts);
    return int.tryParse(val ?? '0') ?? 0;
  }

  /// Records a failed unlock attempt and returns new failed count.
  static Future<int> recordPinFailedAttempt() async {
    final current = await getPinFailedAttempts();
    final newCount = current + 1;
    await _storage.write(key: _keyPinFailedAttempts, value: newCount.toString());

    // Apply progressive lockouts
    final lockoutDuration = _getLockoutDuration(newCount);
    if (lockoutDuration != null) {
      final lockoutUntil = DateTime.now().add(lockoutDuration).millisecondsSinceEpoch;
      await _storage.write(key: _keyPinLockoutUntil, value: lockoutUntil.toString());
    }

    return newCount;
  }

  /// Returns the lockout end time or null if not locked out.
  static Future<DateTime?> getPinLockoutUntil() async {
    final val = await _storage.read(key: _keyPinLockoutUntil);
    if (val == null) return null;
    final millis = int.tryParse(val);
    if (millis == null) return null;
    final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(millis);
    // If lockout has passed, clear it
    if (DateTime.now().isAfter(lockoutUntil)) {
      await _storage.delete(key: _keyPinLockoutUntil);
      return null;
    }
    return lockoutUntil;
  }

  /// Resets failed attempts and lockout after successful auth.
  static Future<void> resetPinFailedAttempts() async {
    await _storage.write(key: _keyPinFailedAttempts, value: '0');
    await _storage.delete(key: _keyPinLockoutUntil);
  }

  // -------------------------------------------------------------------------
  // Transaction PIN Lockout Logic
  // -------------------------------------------------------------------------

  static Future<int> getTransactionPinFailedAttempts() async {
    final val = await _storage.read(key: _keyTransactionPinFailedAttempts);
    return int.tryParse(val ?? '0') ?? 0;
  }

  static Future<int> recordTransactionPinFailedAttempt() async {
    final current = await getTransactionPinFailedAttempts();
    final newCount = current + 1;
    await _storage.write(key: _keyTransactionPinFailedAttempts, value: newCount.toString());

    final lockoutDuration = _getLockoutDuration(newCount);
    if (lockoutDuration != null) {
      final lockoutUntil = DateTime.now().add(lockoutDuration).millisecondsSinceEpoch;
      await _storage.write(key: _keyTransactionPinLockoutUntil, value: lockoutUntil.toString());
    }
    return newCount;
  }

  static Future<DateTime?> getTransactionPinLockoutUntil() async {
    final val = await _storage.read(key: _keyTransactionPinLockoutUntil);
    if (val == null) return null;
    final millis = int.tryParse(val);
    if (millis == null) return null;
    final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(millis);
    if (DateTime.now().isAfter(lockoutUntil)) {
      await _storage.delete(key: _keyTransactionPinLockoutUntil);
      return null;
    }
    return lockoutUntil;
  }

  static Future<void> resetTransactionPinFailedAttempts() async {
    await _storage.write(key: _keyTransactionPinFailedAttempts, value: '0');
    await _storage.delete(key: _keyTransactionPinLockoutUntil);
  }

  // -------------------------------------------------------------------------
  // Progressive lockout schedule
  // Attempts 1-4: no lockout
  // Attempt 5:    30s
  // Attempt 6:    2 min
  // Attempt 7:    10 min
  // Attempt 8+:   30 min
  // -------------------------------------------------------------------------
  static Duration? _getLockoutDuration(int failedCount) {
    switch (failedCount) {
      case 5:
        return const Duration(seconds: 30);
      case 6:
        return const Duration(minutes: 2);
      case 7:
        return const Duration(minutes: 10);
      default:
        if (failedCount >= 8) return const Duration(minutes: 30);
        return null;
    }
  }

  // -------------------------------------------------------------------------
  // PIN Validation (Strength Rules)
  // -------------------------------------------------------------------------

  /// Returns null if PIN is valid, or an error message if invalid.
  static String? validatePinStrength(String pin) {
    if (pin.length != 6) return 'PIN must be exactly 6 digits.';

    // No all-same digits (e.g., 111111)
    if (RegExp(r'^(\d)\1{5}$').hasMatch(pin)) {
      return 'PIN cannot be all the same digit (e.g. 111111).';
    }

    // No sequential ascending (e.g., 123456)
    bool isAscending = true;
    bool isDescending = true;
    for (int i = 1; i < pin.length; i++) {
      final curr = int.parse(pin[i]);
      final prev = int.parse(pin[i - 1]);
      if (curr != prev + 1) isAscending = false;
      if (curr != prev - 1) isDescending = false;
    }
    if (isAscending) return 'PIN cannot be a simple sequence (e.g. 123456).';
    if (isDescending) return 'PIN cannot be a simple sequence (e.g. 654321).';

    return null; // PIN is valid
  }

  // -------------------------------------------------------------------------
  // Security Settings (SharedPreferences — non-sensitive)
  // -------------------------------------------------------------------------

  static Future<bool> isDeviceLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDeviceLockEnabled) ?? false;
  }

  static Future<void> setDeviceLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDeviceLockEnabled, enabled);
  }

  static Future<bool> isBiometricUnlockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricUnlockEnabled) ?? false;
  }

  static Future<void> setBiometricUnlockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricUnlockEnabled, enabled);
  }

  /// Returns configured lock timeout in seconds. Defaults to 300s (5 min).
  static Future<int> getLockTimeoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLockTimeoutSeconds) ?? 300;
  }

  static Future<void> setLockTimeoutSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLockTimeoutSeconds, seconds);
  }

  // -------------------------------------------------------------------------
  // Biometric Credentials
  // -------------------------------------------------------------------------

  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyBiometricEnabled, value: 'true');
  }

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

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceLockEnabled);
    await prefs.remove(_keyBiometricUnlockEnabled);
    await prefs.remove(_keyLockTimeoutSeconds);
  }
}
