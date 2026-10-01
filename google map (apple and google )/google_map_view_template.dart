import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Production-ready Google Map Widget template for Flutter (iOS & Android)
class GoogleMapViewTemplate extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker>? markers;
  final Function(LatLng)? onTap;
  final Function(GoogleMapController)? onMapCreated;
  final bool enableMyLocation;
  final bool enableTraffic;

  const GoogleMapViewTemplate({
    super.key,
    this.initialPosition = const LatLng(30.0444, 31.2357), // Cairo by default
    this.initialZoom = 14.0,
    this.markers,
    this.onTap,
    this.onMapCreated,
    this.enableMyLocation = true,
    this.enableTraffic = false,
  });

  @override
  State<GoogleMapViewTemplate> createState() => _GoogleMapViewTemplateState();
}

class _GoogleMapViewTemplateState extends State<GoogleMapViewTemplate> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  Set<Marker> _markers = {};

  // Custom Dark Mode Map Style JSON
  static const String _darkModeMapStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#212a37"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9ca5b3"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _markers = widget.markers ?? {};
    if (widget.enableMyLocation) {
      _determinePosition();
    }
  }

  /// Request Location Permission and retrieve current GPS coordinates
  Future<void> _determinePosition() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      _animateToLocation(_currentLocation!);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Smooth Camera Animation to specific LatLng
  Future<void> _animateToLocation(LatLng target, {double zoom = 15.5}) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  /// Toggle Map Style between Standard and Satellite
  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
          mapType: _currentMapType,
          markers: _markers,
          myLocationEnabled: widget.enableMyLocation,
          myLocationButtonEnabled: false,
          trafficEnabled: widget.enableTraffic,
          zoomControlsEnabled: false,
          compassEnabled: true,
          style: Theme.of(context).brightness == Brightness.dark
              ? _darkModeMapStyle
              : null,
          onMapCreated: (controller) {
            _controller.complete(controller);
            _mapController = controller;
            widget.onMapCreated?.call(controller);
          },
          onTap: (latLng) {
            setState(() {
              _markers = {
                ..._markers,
                Marker(
                  markerId: const MarkerId('selected_point'),
                  position: latLng,
                  infoWindow: InfoWindow(
                    title: 'الموقع المحدد',
                    snippet: '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
                  ),
                ),
              };
            });
            widget.onTap?.call(latLng);
          },
        ),

        // Map Control Floating Buttons
        Positioned(
          top: 48,
          left: 16,
          child: Column(
            children: [
              // Satellite / Normal Toggle
              FloatingActionButton.small(
                heroTag: 'btn_map_type',
                backgroundColor: Colors.white,
                onPressed: _toggleMapType,
                child: Icon(
                  _currentMapType == MapType.normal ? Icons.satellite_alt : Icons.map,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Current Location Button
              FloatingActionButton.small(
                heroTag: 'btn_my_location',
                backgroundColor: Colors.white,
                onPressed: _determinePosition,
                child: _isLoadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
