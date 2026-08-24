import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';
import '../../../core/components/tw_button.dart';
import '../../wallet/providers/driver_ride_provider.dart';

class DriverActiveRideScreen extends ConsumerStatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  ConsumerState<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends ConsumerState<DriverActiveRideScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  // Dummy location for driver (could use geolocator in production)
  final LatLng _driverLocation = const LatLng(6.5244, 3.3792); 
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drawRoute();
    });
  }
  
  Future<void> _drawRoute() async {
    final rideState = ref.read(driverRideProvider);
    final request = rideState.currentRequest;
    
    if (request == null) return;
    
    final originLat = request['origin_lat'];
    final originLng = request['origin_lng'];
    final destLat = request['dest_lat'];
    final destLng = request['dest_lng'];
    
    LatLng start;
    LatLng end;
    
    if (rideState.status == DriverRideStatus.enRouteToPickup) {
      start = _driverLocation;
      end = LatLng(originLat, originLng);
    } else {
      start = LatLng(originLat, originLng);
      end = LatLng(destLat, destLng);
    }

    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: start,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: end,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });

    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return;

      final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final points = data['routes'][0]['overview_polyline']['points'];
          final decodedPoints = _decodeEncodedPolyline(points);
          
          if (decodedPoints.isNotEmpty) {
            setState(() {
              _polylines.clear();
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: AppColors.kekeGreen,
                  width: 5,
                  points: decodedPoints,
                ),
              );
            });
            
            // Fit bounds
            if (_mapController != null) {
              final bounds = LatLngBounds(
                southwest: LatLng(
                  start.latitude < end.latitude ? start.latitude : end.latitude,
                  start.longitude < end.longitude ? start.longitude : end.longitude,
                ),
                northeast: LatLng(
                  start.latitude > end.latitude ? start.latitude : end.latitude,
                  start.longitude > end.longitude ? start.longitude : end.longitude,
                ),
              );
              _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error drawing route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(driverRideProvider);
    final isEnRoute = rideState.status == DriverRideStatus.enRouteToPickup;
    
    // Automatically redraw route when status changes to inProgress
    ref.listen<DriverRideState>(driverRideProvider, (previous, next) {
      if (previous?.status != next.status && next.status == DriverRideStatus.inProgress) {
        _drawRoute();
      }
      
      if (next.status == DriverRideStatus.idle || next.status == DriverRideStatus.completed) {
        Navigator.pop(context); // Go back to dashboard
      }
    });

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Google Map Background
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _driverLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _drawRoute();
            },
          ),
          
          // Floating Back Button
          Positioned(
            top: 50,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.ink.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.paper),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
          
          // Active Ride Bottom UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withOpacity(0.8),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.danfoYellow.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.navigation, color: AppColors.danfoYellow, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEnRoute ? 'Heading to pickup' : 'On trip to destination',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppColors.paper,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEnRoute 
                                    ? 'Passenger is waiting at origin.'
                                    : 'Follow the route to destination.',
                                  style: GoogleFonts.outfit(color: AppColors.muted, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TWButton(
                              label: 'Cancel',
                              variant: TWButtonVariant.secondary,
                              onPressed: () {
                                ref.read(driverRideProvider.notifier).declineRide();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: AppColors.kekeGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                                ],
                              ),
                              child: TWButton(
                                label: isEnRoute ? 'Arrived & Start Trip' : 'Complete Trip',
                                onPressed: () {
                                  if (isEnRoute) {
                                    ref.read(driverRideProvider.notifier).startTrip();
                                  } else {
                                    ref.read(driverRideProvider.notifier).completeTrip();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Decodes a Google Maps encoded polyline string into a list of LatLng points.
  List<LatLng> _decodeEncodedPolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
