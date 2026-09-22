import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/core/theme/app_theme.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';
import 'package:time_capsule/services/location_service.dart';

class CreateLocationCapsulePage extends StatefulWidget {
  const CreateLocationCapsulePage({super.key});

  @override
  State<CreateLocationCapsulePage> createState() =>
      _CreateLocationCapsulePageState();
}

class _CreateLocationCapsulePageState extends State<CreateLocationCapsulePage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _capsuleService = CapsuleService();
  final _locationService = LocationService();

  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _gettingLocation = true);
    final pos = await _locationService.getCurrentLocation();
    setState(() {
      _gettingLocation = false;
      if (pos != null) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      }
    });
    if (pos == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location')),
      );
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _capsuleService.createCapsule(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: CapsuleType.location,
        latitude: _latitude,
        longitude: _longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location Capsule created successfully! 📍'),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Location Capsule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Geo-Locked Capsule 📍',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Lock a memory to a specific physical place',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Capsule Title',
                hintText: 'e.g., Hidden treasure at the park',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Your Secret Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _latitude != null
                              ? 'Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                              : 'No location selected',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _gettingLocation ? null : _fetchCurrentLocation,
                    icon: _gettingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_searching),
                    label: const Text('Use Current Location'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Seal Location Capsule',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
