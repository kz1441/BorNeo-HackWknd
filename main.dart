import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called.
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(home: DisasterAppHome(cameras: cameras)));
}

class DisasterAppHome extends StatefulWidget {
  final List<CameraDescription> cameras;
  DisasterAppHome({required this.cameras});

  @override
  _DisasterAppHomeState createState() => _DisasterAppHomeState();
}

class _DisasterAppHomeState extends State<DisasterAppHome> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _statusMessage = "Ready to take a picture and get location.";
  String? _capturedImagePath; // Store captured image path
  bool _hasResult = false; // Track if we have a result from Gemini

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera, create a CameraController.
    _controller = CameraController(widget.cameras.first, ResolutionPreset.medium);
    // Initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processDisasterAlert() async {
    setState(() => _statusMessage = "Processing...");
    XFile? image;
    Position? position;

    try {
      // 1. Take Picture FIRST
      setState(() => _statusMessage = "Taking picture...");
      await _initializeControllerFuture;
      image = await _controller.takePicture();
      
      // Immediately show the captured image and hide the FAB
      setState(() {
        _capturedImagePath = image!.path;
        _statusMessage = "Photo captured. Fetching location...";
      });

      // 2. Get GPS Location SECOND
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS is disabled.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Location permission denied.");
      }
      
      position = await Geolocator.getCurrentPosition();

    } catch (e) {
      setState(() => _statusMessage = "Error: $e");
      return; 
    }

    // 3. Send to Gemini Backend THIRD
    setState(() => _statusMessage = "Analyzing with Gemini...");
    await _sendToBackend(position, image);
  }

  Future<void> _sendToBackend(Position position, XFile image) async {
    // IMPORTANT: Replace with your laptop's actual IP address!
    // Do not use 'localhost' if testing on a real phone.
    final url = Uri.parse('http://YOUR_LAPTOP_IPV4_ADDRESS:3000/evaluate');

    try {
      // Convert image to Base64
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      String myLocationId = "LOCATION:1";

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "locationId": myLocationId, // NEW: Sending the district ID
          "imageBase64": base64Image,
          "mimeType": "image/jpeg"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _statusMessage = """
AI Result: ${data['result']}
Your Location: ${position.latitude}, ${position.longitude}
Local Forecast: ${data['forecast']}
""";
          _hasResult = true; // Mark that we have a result
        });
      } else {
        setState(() => _statusMessage = "Backend Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _statusMessage = "Error sending data: $e");
    }
  }

  void _resetToCamera() {
    setState(() {
      _capturedImagePath = null;
      _hasResult = false;
      _statusMessage = "Ready to take a picture and get location.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Disaster App")),
      body: SingleChildScrollView( // Add scrolling just in case
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Always center horizontally
          children: [
            // Fix: Constrain the camera height so it doesn't push text off-screen
            SizedBox(
              width: double.infinity, // Take full width to ensure centering
              height: MediaQuery.of(context).size.height * 0.5, // Uses 50% of screen height
              child: _capturedImagePath != null
                  ? Center(
                      child: Image.file(
                        File(_capturedImagePath!),
                        fit: BoxFit.contain,
                      ),
                    )
                  : FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Center(child: CameraPreview(_controller));
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            // Show "Take New Photo" button when we have a result
            if (_hasResult) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _resetToCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take New Photo"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (_capturedImagePath != null || _hasResult)
          ? null // Hide FAB when showing result
          : FloatingActionButton.extended(
              onPressed: _processDisasterAlert,
              icon: const Icon(Icons.emergency_share),
              label: const Text("Analyze Situation"),
            ),
    );
  }
}