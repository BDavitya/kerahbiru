import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import 'home_page.dart';
import '../utils/session_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  double? latitude;
  double? longitude;
  bool isLoadingLocation = false;
  bool isSubmitting = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Ambil lokasi user saat ini
  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak secara permanen';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;

        // Update marker
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(latitude!, longitude!),
            infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          ),
        };

        // Pindahkan kamera ke lokasi
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(latitude!, longitude!),
            15,
          ),
        );
      });

      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Lokasi berhasil didapatkan!',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Gagal mendapatkan lokasi: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> _submitProfile() async {
    if (phoneController.text.isEmpty || addressController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Semua kolom wajib diisi!',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (latitude == null || longitude == null) {
      CustomSnackbar.show(
        context,
        message: 'Harap ambil lokasi Anda terlebih dahulu!',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final response = await ApiService.completeProfile(
        phone: phoneController.text,
        address: addressController.text,
        latitude: latitude!,
        longitude: longitude!,
      );

      if (response['success'] == true) {
        // Update session bahwa profile sudah lengkap
        await SessionManager.saveUser(response['user']);

        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Profile berhasil dilengkapi!',
            backgroundColor: Colors.green,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        throw response['message'] ?? 'Gagal melengkapi profile';
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Error: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Lengkapi Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang! 👋',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A70A9),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mohon lengkapi data Anda untuk melanjutkan.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // No HP
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'No. HP / WhatsApp',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF4A70A9)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Alamat
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                prefixIcon: const Icon(Icons.home, color: Color(0xFF4A70A9)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Button Ambil Lokasi
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoadingLocation ? null : _getCurrentLocation,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF4A70A9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isLoadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, color: Color(0xFF4A70A9)),
                label: Text(
                  latitude != null
                      ? 'Lokasi Sudah Didapat ✓'
                      : 'Ambil Lokasi Saya',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF4A70A9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4A70A9)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude!, longitude!),
                      zoom: 15,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${latitude!.toStringAsFixed(6)}, Lng: ${longitude!.toStringAsFixed(6)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Button Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A70A9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan & Lanjutkan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
