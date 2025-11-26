import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class SensorsPage extends StatefulWidget {
  const SensorsPage({Key? key}) : super(key: key);

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  double accelX = 0.0, accelY = 0.0, accelZ = 0.0;
  bool isShaking = false;

  double gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;

  double magX = 0.0, magY = 0.0, magZ = 0.0;

  double heading = 0.0;
  String direction = 'N';
  bool compassAvailable = false;

  double latitude = 0.0, longitude = 0.0;
  double altitude = 0.0, speed = 0.0, accuracy = 0.0;
  String locationStatus = 'Not fetched';
  bool locationPermissionGranted = false;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSensors();
    _checkLocationPermission();
  }

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        setState(() {
          accelX = event.x;
          accelY = event.y;
          accelZ = event.z;

          double magnitude = sqrt(
            accelX * accelX + accelY * accelY + accelZ * accelZ,
          );
          isShaking = magnitude > 20;
        });
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );

    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        setState(() {
          gyroX = event.x;
          gyroY = event.y;
          gyroZ = event.z;
        });
      },
      onError: (error) {
        debugPrint('Gyroscope error: $error');
      },
    );

    _magnetometerSubscription = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        setState(() {
          magX = event.x;
          magY = event.y;
          magZ = event.z;
        });
      },
      onError: (error) {
        debugPrint('Magnetometer error: $error');
      },
    );

    _compassSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        setState(() {
          compassAvailable = true;
          heading = event.heading ?? 0;
          direction = _getDirection(heading);
        });
      },
      onError: (error) {
        debugPrint('Compass error: $error');
        setState(() {
          compassAvailable = false;
        });
      },
    );

    if (_compassSubscription == null) {
      setState(() {
        compassAvailable = false;
      });
    }
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N ⬆️';
    if (heading >= 22.5 && heading < 67.5) return 'NE ↗️';
    if (heading >= 67.5 && heading < 112.5) return 'E ➡️';
    if (heading >= 112.5 && heading < 157.5) return 'SE ↘️';
    if (heading >= 157.5 && heading < 202.5) return 'S ⬇️';
    if (heading >= 202.5 && heading < 247.5) return 'SW ↙️';
    if (heading >= 247.5 && heading < 292.5) return 'W ⬅️';
    return 'NW ↖️';
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      setState(() {
        locationPermissionGranted =
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      });
    } catch (e) {
      debugPrint('Location permission error: $e');
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      locationStatus = 'Fetching location...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationStatus = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationStatus =
              'Location permission denied forever. Enable in settings.';
        });
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationStatus = 'Location services are disabled';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        altitude = position.altitude;
        speed = position.speed;
        accuracy = position.accuracy;
        locationStatus = 'Location fetched successfully ✓';
        locationPermissionGranted = true;
      });
    } catch (e) {
      setState(() {
        locationStatus = 'Error: ${e.toString()}';
      });
      debugPrint('Location error: $e');
    }
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();

    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            setState(() {
              latitude = position.latitude;
              longitude = position.longitude;
              altitude = position.altitude;
              speed = position.speed;
              accuracy = position.accuracy;
              locationStatus = 'Tracking... ✓';
            });
          },
          onError: (error) {
            setState(() {
              locationStatus = 'Tracking error: $error';
            });
          },
        );
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    setState(() {
      locationStatus = 'Tracking stopped';
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Sensors Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSensorCard(
              'Accelerometer',
              Icons.vibration,
              Colors.blue,
              [
                'X: ${accelX.toStringAsFixed(2)} m/s²',
                'Y: ${accelY.toStringAsFixed(2)} m/s²',
                'Z: ${accelZ.toStringAsFixed(2)} m/s²',
                'Magnitude: ${sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ).toStringAsFixed(2)} m/s²',

                if (isShaking) '🔔 Device is shaking!',
              ],
              subtitle: 'Measures acceleration including gravity',
            ),

            _buildSensorCard(
              'Gyroscope',
              Icons.rotate_right,
              Colors.purple,
              [
                'X: ${gyroX.toStringAsFixed(3)} rad/s',
                'Y: ${gyroY.toStringAsFixed(3)} rad/s',
                'Z: ${gyroZ.toStringAsFixed(3)} rad/s',
                'Total rotation: ${sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ).toStringAsFixed(3)} rad/s',
              ],
              subtitle: 'Measures rotation rate around each axis',
            ),

            _buildSensorCard(
              'Magnetometer',
              Icons.screen_rotation,
              Colors.indigo,
              [
                'X: ${magX.toStringAsFixed(2)} µT',
                'Y: ${magY.toStringAsFixed(2)} µT',
                'Z: ${magZ.toStringAsFixed(2)} µT',
                'Field strength: ${sqrt(magX * magX + magY * magY + magZ * magZ).toStringAsFixed(2)} µT',
              ],
              subtitle: 'Measures magnetic field strength',
            ),

            _buildSensorCard(
              'Compass',
              Icons.explore,
              Colors.green,
              compassAvailable
                  ? [
                      'Heading: ${heading.toStringAsFixed(1)}°',
                      'Direction: $direction',
                      '',
                      'Rotate your device to see changes',
                    ]
                  : [
                      'Compass not available on this device',
                      'or permission not granted',
                    ],
              subtitle: 'Shows device heading relative to North',
            ),

            _buildSensorCard(
              'GPS / Location',
              Icons.location_on,
              Colors.red,
              [
                'Latitude: ${latitude.toStringAsFixed(6)}°',
                'Longitude: ${longitude.toStringAsFixed(6)}°',
                'Altitude: ${altitude.toStringAsFixed(1)} m',
                'Speed: ${speed.toStringAsFixed(1)} m/s',
                'Accuracy: ${accuracy.toStringAsFixed(1)} m',
                '',
                'Status: $locationStatus',
              ],
              subtitle: 'Provides geographical position',
              action: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Get Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _locationSubscription == null
                          ? _startLocationTracking
                          : _stopLocationTracking,
                      icon: Icon(
                        _locationSubscription == null
                            ? Icons.play_arrow
                            : Icons.stop,
                        size: 18,
                      ),
                      label: Text(
                        _locationSubscription == null ? 'Track' : 'Stop',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _locationSubscription == null
                            ? Colors.green
                            : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Dependencies in pubspec.yaml',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'dependencies:\n'
                      '''sensors_plus: ^7.0.0
  geolocator: ^14.0.2
  flutter_compass: ^0.8.1''',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '💡 All sensors except NFC are working!\n'
                    'Shake your device to test accelerometer.\n'
                    'Rotate to see compass changes.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    IconData icon,
    Color color,
    List<String> data, {
    String? subtitle,
    Widget? action,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(line, style: const TextStyle(fontSize: 14)),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}
