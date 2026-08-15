import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final kycServiceProvider = Provider<MockKYCService>((ref) {
  return MockKYCService();
});

/// A mock service that mimics the JSON response shape of a real Nigerian KYC provider (e.g. Dojah).
/// When you are ready for production, simply replace the contents of [verifyBVN] with a real HTTP call.
class MockKYCService {
  
  /// Simulates a real BVN verification call.
  Future<Map<String, dynamic>> verifyBVN(String bvn) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real integration, you would use http.post to your backend or the provider.
    // E.g.
    // final response = await http.post('https://api.dojah.io/api/v1/kyc/bvn', headers: {...}, body: {"bvn": bvn});
    // return jsonDecode(response.body);
    
    if (bvn.length != 11) {
      return {
        'status': false,
        'message': 'Invalid BVN length. Must be 11 digits.',
      };
    }
    
    // Simulate a failure for a specific "bad" BVN for testing purposes
    if (bvn == '00000000000') {
      return {
        'status': false,
        'message': 'BVN not found in NIBSS database.',
      };
    }
    
    // Simulate successful JSON response
    return {
      'status': true,
      'message': 'BVN verified successfully',
      'data': {
        'bvn': bvn,
        'first_name': 'John',
        'last_name': 'Doe',
        'date_of_birth': '1990-01-01',
        'phone_number': '08012345678',
        'gender': 'Male',
      }
    };
  }
}
