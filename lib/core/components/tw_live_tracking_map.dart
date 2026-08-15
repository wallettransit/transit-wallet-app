import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';

class TWLiveTrackingMap extends StatefulWidget {
  final double height;
  final LatLng? currentLocation;
  final LatLng? destination;

  const TWLiveTrackingMap({
    super.key, 
    this.height = 200,
    this.currentLocation,
    this.destination,
  });

  @override
  State<TWLiveTrackingMap> createState() => _TWLiveTrackingMapState();
}

class _TWLiveTrackingMapState extends State<TWLiveTrackingMap> {
  GoogleMapController? _mapController;
  
  // Default to Lagos, Nigeria
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 14.4746,
  );

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};
    
    // Add vehicle marker (mocked or real)
    final vehiclePos = widget.currentLocation ?? const LatLng(6.5244, 3.3792);
    markers.add(
      Marker(
        markerId: const MarkerId('vehicle'),
        position: vehiclePos,
        infoWindow: const InfoWindow(title: 'Danfo'),
        // In a real app we'd load a custom bitmap icon here for the danfo
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      )
    );

    // Add destination if provided
    if (widget.destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination!,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        )
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderStroke),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, color: AppColors.muted, size: 40),
              const SizedBox(height: 8),
              Text(
                'Map Preview\n(Mobile Only)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStroke),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            
            // Set dark mode style
            _mapController?.setMapStyle(_darkMapStyle);
          },
          markers: _createMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  // A basic dark mode JSON style for Google Maps to match our app aesthetics
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9e9e9e"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#bdbdbd"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#181818"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#1b1b1b"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#8a8a8a"}]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [{"color": "#373737"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#3c3c3c"}]
    },
    {
      "featureType": "road.highway.controlled_access",
      "elementType": "geometry",
      "stylers": [{"color": "#4e4e4e"}]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#3d3d3d"}]
    }
  ]
  ''';
}
