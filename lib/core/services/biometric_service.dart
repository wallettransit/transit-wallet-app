import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device supports biometric authentication
  static Future<bool> isBiometricSupported() async {
    if (kIsWeb) return false;
    
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (e) {
      // Catching generic Exception to handle MissingPluginException on unsupported platforms
      print('Error checking biometric support: $e');
      return false;
    }
  }

  /// Attempts to authenticate the user using biometrics (FaceID / TouchID).
  /// Returns `true` if successful, `false` otherwise.
  static Future<bool> authenticate({String reason = 'Authenticate to access OyaPayWallet'}) async {
    try {
      final isSupported = await isBiometricSupported();
      if (!isSupported) return false;

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'OyaPayWallet Security',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      // Catching generic Exception to handle MissingPluginException
      print('Error authenticating with biometrics: $e');
      return false;
    }
  }
}
