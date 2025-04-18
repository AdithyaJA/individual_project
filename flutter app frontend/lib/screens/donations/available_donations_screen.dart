import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/donation_service.dart';
import 'package:frontend/utils/distance_utils.dart';
import 'donation_details_screen.dart';

class AvailableDonationsScreen extends StatefulWidget {
  const AvailableDonationsScreen({super.key});

  @override
  State<AvailableDonationsScreen> createState() => _AvailableDonationsScreenState();
}

class _AvailableDonationsScreenState extends State<AvailableDonationsScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final allDonations = await DonationService.getAllAvailableDonations();

   final filtered = allDonations.where((donation) {
  final lat = donation['location']['lat'];
  final lng = donation['location']['lng'];
  final distance = DistanceUtils.calculateDistance(position.latitude, position.longitude, lat, lng);
  return distance <= 100.0 && donation['status'] == 'pending';
}).toList();


    Set<Marker> markers = {};
    for (var d in filtered) {
      final lat = d['location']['lat'];
      final lng = d['location']['lng'];

      markers.add(
        Marker(
          markerId: MarkerId(d['_id']),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: d['description'],
            snippet: 'Qty: ${d['quantity']}',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DonationDetailsScreen(donation: d),
                ),
              );
            },
          ),
        ),
      );
    }

    setState(() {
      _currentPosition = position;
      _markers = markers;
      _isLoading = false;
    });
  }

  Future<void> _applyMapStyle(GoogleMapController controller) async {
    final style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
    controller.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Donations (within 20km)")),
      body: _isLoading || _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: const LatLng(7.8731, 80.7718), // Sri Lanka
                zoom: 7.5,
              ),
              myLocationEnabled: true,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) async {
                _mapController.complete(controller);
                await _applyMapStyle(controller);
              },
              minMaxZoomPreference: const MinMaxZoomPreference(7, 18),
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),
    );
  }
}
