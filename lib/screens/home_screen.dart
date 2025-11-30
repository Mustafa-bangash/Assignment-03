import 'dart:async'; // NEW IMPORT for StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'capture_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use MapController to allow the map to follow the user
  final MapController _mapController = MapController();

  // StreamSubscription to listen for continuous updates
  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng _currentPosition = LatLng(33.6844, 73.0479); // Default: Islamabad
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // Start listening for position updates when the screen loads
    _startListeningForLocation();
  }

  @override
  void dispose() {
    // CRITICAL: Cancel the subscription when the widget is destroyed
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // New method to handle both permission check and stream setup
  Future<void> _startListeningForLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {

      // Get the initial position once
      Position initialPosition = await Geolocator.getCurrentPosition();
      _updateMap(initialPosition);

      // Set up the stream for continuous updates (Live Tracking!)
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update every 5 meters moved
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
              (Position? position) {
            if (position != null) {
              _updateMap(position);
            }
          },
          onError: (e) {
            print("Error receiving location update: $e");
          }
      );
    }
  }

  // Helper function to update the map state
  // Helper function to update the map state
  void _updateMap(Position position) {
    final newLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = newLatLng;
      _markers = [ // Update marker list
        Marker(
          point: _currentPosition,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        )
      ];
    });

    // FIX: Use the 'move' method, which is correct for flutter_map
    // Remove the old _mapController.animateCamera(...) block entirely.
    _mapController.move(
      _currentPosition, // The new LatLng position
      _mapController.camera.zoom, // Keep the current zoom level
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartTracker Home')),
      body: FlutterMap(
        // Pass the controller to the map
        mapController: _mapController,
        options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            )
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.smarttracker',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            child: const Icon(Icons.history),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => HistoryScreen())),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn2",
            child: const Icon(Icons.camera_alt),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => CaptureScreen())),
          ),
        ],
      ),
    );
  }
}