import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import 'complete_profil_page.dart';

class ShakeVerificationPage extends StatefulWidget {
  const ShakeVerificationPage({super.key});

  @override
  State<ShakeVerificationPage> createState() => _ShakeVerificationPageState();
}

class _ShakeVerificationPageState extends State<ShakeVerificationPage>
    with SingleTickerProviderStateMixin {
  int shakeCount = 0;
  final int requiredShakes = 100;
  bool isShaking = false;
  bool isVerifying = false;
  StreamSubscription? _accelerometerSubscription;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startShakeDetection() {
    if (isShaking) return;

    setState(() {
      isShaking = true;
      shakeCount = 0;
    });

    _animController.repeat(reverse: true);

    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (acceleration > 25) {
        setState(() {
          shakeCount++;
          if (shakeCount >= requiredShakes) {
            _stopAndVerify();
          }
        });
      }
    });
  }

  Future<void> _stopAndVerify() async {
    _accelerometerSubscription?.cancel();
    _animController.stop();

    setState(() {
      isShaking = false;
      isVerifying = true;
    });

    try {
      final response = await ApiService.verifyShakeCaptcha();

      if (response['success'] == true) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Verifikasi berhasil! Silakan lengkapi profil.',
            backgroundColor: Colors.green,
          );

          await Future.delayed(const Duration(milliseconds: 500));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
          );
        }
      } else {
        throw response['message'] ?? 'Verifikasi gagal';
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
      setState(() => isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = shakeCount / requiredShakes;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 80,
                color: Color(0xFF4A70A9),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verifikasi Keamanan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A70A9),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Goyang HP kamu untuk membuktikan\nbahwa kamu adalah manusia!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),

              // Progress Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF4A70A9)),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$shakeCount',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A70A9),
                        ),
                      ),
                      Text(
                        '/ $requiredShakes',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Shake Button
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      isShaking ? sin(_animController.value * 2 * pi) * 10 : 0,
                      0,
                    ),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: isVerifying ? null : _startShakeDetection,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isVerifying ? Colors.grey : const Color(0xFF4A70A9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A70A9).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      isVerifying
                          ? Icons.hourglass_empty
                          : isShaking
                              ? Icons.vibration
                              : Icons.touch_app,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                isVerifying
                    ? 'Memverifikasi...'
                    : isShaking
                        ? 'Terus goyang!'
                        : 'Ketuk untuk mulai',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A70A9),
                ),
              ),

              if (isVerifying)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
