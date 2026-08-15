import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class LocationService {
  /// Check permissions and get current position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get human readable address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Build address string (e.g., "Oshodi, Lagos")
        String address = '';
        
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += '${place.subLocality}, ';
        } else if (place.street != null && place.street!.isNotEmpty) {
           address += '${place.street}, ';
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += '${place.locality}';
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += '${place.administrativeArea}';
        }
        
        return address.trim().replaceAll(RegExp(r',$'), '');
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Location not found';
    }
  }
  
  /// Helper to do both: get position and return address string
  Future<String> getCurrentAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position != null) {
        return await getAddressFromCoordinates(position.latitude, position.longitude);
      }
      return '';
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
