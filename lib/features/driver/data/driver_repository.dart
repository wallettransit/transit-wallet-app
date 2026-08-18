import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(Supabase.instance.client);
});

class DriverRepository {
  final SupabaseClient _client;

  DriverRepository(this._client);

  Future<Map<String, dynamic>> submitKYC({
    required String userId,
    required String bvnOrNin,
  }) async {
    try {
      await _client
          .from('users')
          .update({
            'bvn_or_nin': bvnOrNin,
            'role': 'driver',
          })
          .eq('id', userId);
          
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit KYC: $e'};
    }
  }

  Future<Map<String, dynamic>> registerVehicle({
    required String driverId,
    required String plateNumber,
    required String vehicleType,
  }) async {
    try {
      final response = await _client
          .from('vehicles')
          .insert({
            'driver_id': driverId,
            'plate_number': plateNumber,
            'vehicle_type': vehicleType.toLowerCase(),
          })
          .select('id')
          .single();
          
      return {'success': true, 'vehicle_id': response['id']};
    } catch (e) {
      return {'success': false, 'message': 'Failed to register vehicle: $e'};
    }
  }

  Future<Map<String, dynamic>> setupDriverVehicle({
    required String vehicleType,
    required String licensePlate,
    required String manufacturer,
    required String color,
    required String photoPath, // local file path
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // 1. Upload photo
      String photoUrl = '';
      if (photoPath.contains('mock_path')) {
        photoUrl = 'https://example.com/mock_vehicle.jpg';
      } else {
        final file = File(photoPath);
        final ext = photoPath.split('.').last;
        final storagePath = '${user.id}/vehicle_${DateTime.now().millisecondsSinceEpoch}.$ext';
        
        await _client.storage.from('vehicles').upload(
          storagePath, 
          file,
        );
        photoUrl = _client.storage.from('vehicles').getPublicUrl(storagePath);
      }

      // 2. Call Edge Function
      final response = await _client.functions.invoke(
        'driver-vehicle-setup',
        body: {
          'driverId': user.id,
          'vehicleType': vehicleType,
          'licensePlate': licensePlate,
          'manufacturer': manufacturer,
          'color': color,
          'photoUrl': photoUrl,
        },
      );

      if (response.status != 200 || response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Setup failed');
      }

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Failed to setup vehicle: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadDriverDocuments({
    required Map<String, String> documents, // { 'license': '/path/to/file.jpg' }
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      List<Map<String, String>> uploadedDocs = [];

      // 1. Upload all documents
      for (final docEntry in documents.entries) {
        final docType = docEntry.key;
        final localPath = docEntry.value;
        
        String url = '';
        if (localPath.contains('mock_path')) {
          url = 'https://example.com/mock_document_$docType.jpg';
        } else {
          final file = File(localPath);
          final ext = localPath.split('.').last;
          final storagePath = '${user.id}/${docType}_${DateTime.now().millisecondsSinceEpoch}.$ext';
          
          await _client.storage.from('documents').upload(
            storagePath, 
            file,
          );
          url = _client.storage.from('documents').getPublicUrl(storagePath);
        }

        uploadedDocs.add({
          'type': docType,
          'url': url,
        });
      }

      // 2. Call Edge Function
      final response = await _client.functions.invoke(
        'driver-document-upload',
        body: {
          'driverId': user.id,
          'documents': uploadedDocs,
        },
      );

      if (response.status != 200 || response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Upload failed');
      }

      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': 'Failed to upload documents: $e'};
    }
  }

  Future<Map<String, dynamic>> setupRoute({
    required String vehicleId,
    required String origin,
    required String destination,
    required List<Map<String, dynamic>> fareTiers,
  }) async {
    try {
      // 1. Create Route
      final routeResponse = await _client
          .from('routes')
          .insert({
            'vehicle_id': vehicleId,
            'origin': origin,
            'destination': destination,
            'status': 'active',
          })
          .select('id')
          .single();
          
      final String routeId = routeResponse['id'];

      // 2. Create Fare Tiers (convert Naira to Kobo before inserting)
      final List<Map<String, dynamic>> tiersToInsert = fareTiers.map((tier) {
        return {
          'route_id': routeId,
          'stop_name': tier['stop_name'],
          'stop_order': tier['stop_order'],
          'fare_kobo': ((tier['fare'] as double) * 100).toInt(),
        };
      }).toList();

      await _client.from('fare_tiers').insert(tiersToInsert);
      
      // 3. Generate Driver QR Code
      final String qrPayload = 'TW-DRIVER-${DateTime.now().millisecondsSinceEpoch}';
      
      final codeResponse = await _client
          .from('driver_codes')
          .insert({
            'vehicle_id': vehicleId,
            'route_id': routeId,
            'qr_payload': qrPayload,
          })
          .select('id, qr_payload')
          .single();

      return {
        'success': true, 
        'route_id': routeId,
        'code_id': codeResponse['id'],
        'qr_payload': codeResponse['qr_payload'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to setup route: $e'};
    }
  }

  // Used by the dashboard
  Future<Map<String, dynamic>?> getActiveDriverProfile(String driverId) async {
    try {
      final vehicle = await _client
          .from('vehicles')
          .select('id, plate_number, vehicle_type, routes(id, origin, destination, driver_codes(qr_payload))')
          .eq('driver_id', driverId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
          
      return vehicle;
    } catch (e) {
      print('Error fetching driver profile: $e');
      return null;
    }
  }
}
