import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// หน้า Map ของแอป Time Capsule
/// ใช้ flutter_map (OpenStreetMap) แสดงตำแหน่งปัจจุบันของผู้ใช้
///
/// TODO: ในอนาคตให้ดึง Capsule ที่มี location lock จาก Supabase มาแสดงเป็น
/// Marker เพิ่มเติมบนแผนที่
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;

  static const Color _background = Color(0xFF0B0B1E);
  static const Color _purple = Color(0xFF651FFF);
  static const Color _purpleLight = Color(0xFF9D7CFF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFA8A7C0);

  // ตำแหน่งเริ่มต้นก่อนหาตำแหน่งจริงเจอ (กรุงเทพฯ)
  static const LatLng _defaultLocation = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw 'กรุณาเปิด Location Service ของเครื่อง';
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw 'แอปไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'กรุณาเปิดสิทธิ์ตำแหน่งในการตั้งค่าเครื่อง';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final newLocation = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _currentLocation = newLocation;
        _isLoading = false;
      });

      _mapController.move(newLocation, 16);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Map',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Your current location',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? _defaultLocation,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.time_capsule',
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 64,
                      height: 64,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: _purpleLight, width: 2),
                        ),
                        child: const Icon(
                          Icons.location_pin,
                          color: _purpleLight,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),

              // TODO: เพิ่ม MarkerLayer อีกชุดสำหรับแสดง Capsule
              // ที่มี location lock
            ],
          ),

          // Location status card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _LocationStatusCard(
              isLoading: _isLoading,
              hasLocation: _currentLocation != null,
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 84,
              left: 16,
              right: 16,
              child: _ErrorCard(
                message: _errorMessage!,
                onClose: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
            ),

          // Bottom location button
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _LocationButton(
              isLoading: _isLoading,
              onPressed: _getCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatusCard extends StatelessWidget {
  final bool isLoading;
  final bool hasLocation;

  const _LocationStatusCard({
    required this.isLoading,
    required this.hasLocation,
  });

  static const Color surface = Color(0xFF15152B);
  static const Color purple = Color(0xFF651FFF);
  static const Color purpleLight = Color(0xFF9D7CFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA8A7C0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isLoading
                  ? Icons.gps_not_fixed_rounded
                  : hasLocation
                  ? Icons.my_location_rounded
                  : Icons.location_searching_rounded,
              color: purpleLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading
                      ? 'Finding your location'
                      : hasLocation
                      ? 'Location found'
                      : 'Location unavailable',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isLoading
                      ? 'Please wait a moment...'
                      : hasLocation
                      ? 'Your current position is shown on the map'
                      : 'Try getting your location again',
                  style: const TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: purpleLight,
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ErrorCard({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF351A2A).withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: Colors.redAccent,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LocationButton({required this.isLoading, required this.onPressed});

  static const Color purple = Color(0xFF651FFF);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [purple, Color(0xFF7C4DFF)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.my_location_rounded, color: Colors.white),
        label: Text(
          isLoading ? 'Finding location...' : 'Get My Location',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
