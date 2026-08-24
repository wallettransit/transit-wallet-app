import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/wallet_repository.dart';
import '../data/ride_booking_repository.dart';
import '../data/location_repository.dart';
import 'widgets/transit_bottom_sheet.dart';
import 'widgets/trip_preview_sheet.dart';
import 'location_search_screen.dart';

class PassengerMapHomeScreen extends ConsumerStatefulWidget {
  const PassengerMapHomeScreen({super.key});

  @override
  ConsumerState<PassengerMapHomeScreen> createState() =>
      _PassengerMapHomeScreenState();
}

class _PassengerMapHomeScreenState
    extends ConsumerState<PassengerMapHomeScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Default to Lagos if GPS unavailable
  LatLng _userLocation = const LatLng(6.5244, 3.3792);
  bool _locationObtained = false;
  bool _isBalanceHidden = false;

  @override
  void initState() {
    super.initState();
    _generateMockDrivers();
    _getUserLocation();
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationObtained = true;
      });

      // Animate camera to actual user location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userLocation, zoom: 15.0),
        ),
      );

      // Refresh mock drivers around actual position
      _generateMockDrivers();
    } catch (_) {
      // Keep default Lagos coords
    }
  }

  void _generateMockDrivers() {
    final random = Random();
    final Set<Marker> markers = {};
    for (int i = 0; i < 5; i++) {
      final latOffset = (random.nextDouble() - 0.5) * 0.03;
      final lngOffset = (random.nextDouble() - 0.5) * 0.03;
      markers.add(
        Marker(
          markerId: MarkerId('driver_$i'),
          position: LatLng(
            _userLocation.latitude + latOffset,
            _userLocation.longitude + lngOffset,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Available Driver'),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_locationObtained) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userLocation, zoom: 15.0),
        ),
      );
    }
  }

  // ── Route Drawing ──────────────────────────────────────────────────────────

  Future<void> _drawRoute(String encodedPolyline, LatLng destination) async {
    final latLngPoints = _decodeEncodedPolyline(encodedPolyline);

    // Add destination marker
    final destMarker = Marker(
      markerId: const MarkerId('destination'),
      position: destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(title: 'Destination'),
    );

    // Add origin marker
    final originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: _userLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Your Location'),
    );

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: latLngPoints,
          color: AppColors.kekeGreen,
          width: 5,
          patterns: [],
        ),
      };
      // Keep drivers + add origin/destination pins
      _markers = {
        ..._markers.where((m) =>
            m.markerId.value != 'destination' &&
            m.markerId.value != 'origin'),
        destMarker,
        originMarker,
      };
    });

    // Fit both origin and destination in view
    if (latLngPoints.isNotEmpty) {
      final bounds = _boundsFromLatLngList([_userLocation, destination]);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;
    for (final p in list) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  // ── Search Handler ─────────────────────────────────────────────────────────

  Future<void> _openSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );

    if (result == null) return;

    if (result == 'current_location') {
      // Just zoom to user
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userLocation, zoom: 15.0),
        ),
      );
      return;
    }

    // It's a PlacePrediction — kick off fare estimation
    final prediction = result as PlacePrediction;
    await ref
        .read(rideBookingProvider.notifier)
        .estimateTrip(prediction: prediction, userLocation: _userLocation);

    // Draw route if we have an estimate
    final state = ref.read(rideBookingProvider);
    if (state.estimate != null) {
      await _drawRoute(
        state.estimate!.polyline,
        state.estimate!.destination,
      );
    }
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _markers.removeWhere((m) =>
          m.markerId.value == 'destination' ||
          m.markerId.value == 'origin');
      _generateMockDrivers();
    });
    ref.read(rideBookingProvider.notifier).reset();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final bookingState = ref.watch(rideBookingProvider);

    final metadata = currentUser?.userMetadata ?? {};
    final fullName = metadata['full_name'] as String? ?? 'Passenger';

    String initials = 'P';
    if (fullName.isNotEmpty && fullName != 'Passenger') {
      final parts = fullName.split(' ');
      if (parts.length > 1 && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = fullName.substring(0, 1).toUpperCase();
      }
    }

    final isPreviewOrBooking = bookingState.status == BookingStatus.preview ||
        bookingState.status == BookingStatus.booking ||
        bookingState.status == BookingStatus.booked;
    final isEstimating = bookingState.status == BookingStatus.estimating;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // ── Full Screen Map ──────────────────────────────────────────────
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // ── Floating Wallet Header ───────────────────────────────────────
          if (!isPreviewOrBooking)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(32),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.kekeGreen,
                              child: Text(
                                initials,
                                style: AppTypography.heading3.copyWith(
                                    color: AppColors.ink, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style: AppTypography.bodySmall
                                      .copyWith(color: Colors.white70),
                                ),
                                walletBalanceAsync.when(
                                  data: (balance) => Row(
                                    children: [
                                      Text(
                                        _isBalanceHidden
                                            ? '₦ ••••'
                                            : '₦ ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                        style: AppTypography.heading3
                                            .copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => setState(() =>
                                            _isBalanceHidden =
                                                !_isBalanceHidden),
                                        child: Icon(
                                          _isBalanceHidden
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  loading: () => const SizedBox(
                                    width: 60,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.kekeGreen,
                                    ),
                                  ),
                                  error: (_, __) => Text('Error',
                                      style: AppTypography.bodySmall
                                          .copyWith(color: AppColors.errorRed)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fade().slideY(begin: -0.2),
              ),
            ),

          // ── Estimating Loader ────────────────────────────────────────────
          if (isEstimating)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.kekeGreen,
                      strokeWidth: 2,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Calculating route…',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // ── Back/Cancel button when route is shown ───────────────────────
          if (isPreviewOrBooking)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _clearRoute,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
              ),
            ),

          // ── Bottom: Transit Sheet OR Trip Preview ────────────────────────
          if (isPreviewOrBooking)
            Align(
              alignment: Alignment.bottomCenter,
              child: TripPreviewSheet(),
            )
          else
            TransitBottomSheet(onSearchTap: _openSearch),
        ],
      ),
    );
  }
}
