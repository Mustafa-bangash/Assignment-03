import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';

class CaptureScreen extends StatefulWidget {
  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras.first, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndSave() async {
    setState(() => _isSaving = true);
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final position = await Geolocator.getCurrentPosition();

      // Convert image to Base64 for simple API storage (Mock requirement)
      File imgFile = File(image.path);
      List<int> imageBytes = await imgFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final newActivity = ActivityModel(
        id: DateTime.now().toString(),
        latitude: position.latitude,
        longitude: position.longitude,
        imagePath: base64Image,
        timestamp: DateTime.now().toIso8601String(),
      );

      await Provider.of<ActivityProvider>(context, listen: false).addActivity(newActivity);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Activity')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller!)),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _isSaving
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                    icon: Icon(Icons.camera),
                    label: Text("Snap & Log"),
                    onPressed: _captureAndSave,
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}