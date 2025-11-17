import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  AccelerometerEvent? _lastEvent;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.98,
      upperBound: 1.06,
    );

    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _startShakeDetection() {
    if (isShaking || isVerifying) return;

    setState(() {
      isShaking = true;
      shakeCount = 0;
    });

    // small pulsing animation while shaking
    _scaleController.repeat(reverse: true);

    // Use delta between subsequent events to detect shaking (more reliable than raw magnitude)
    const double shakeThreshold =
        2.5; // tweak: sensitivity for delta (works well on most devices)

    _lastEvent = null;
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!mounted) return;

      if (_lastEvent != null) {
        final dx = (event.x - _lastEvent!.x);
        final dy = (event.y - _lastEvent!.y);
        final dz = (event.z - _lastEvent!.z);

        final delta = sqrt(dx * dx + dy * dy + dz * dz);

        // increment when delta passes threshold
        if (delta > shakeThreshold) {
          setState(() {
            // increment with small cap to avoid accidental double-counting
            shakeCount += 1;
            if (shakeCount >= requiredShakes) {
              _stopAndVerify();
            }
          });
        }
      }

      _lastEvent = event;
    });
  }

  Future<void> _stopAndVerify() async {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _scaleController.stop();
    _lastEvent = null;

    setState(() {
      isShaking = false;
      isVerifying = true;
    });

    try {
      final response = await ApiService.verifyShakeCaptcha();

      if (response != null && response['success'] == true && mounted) {
        CustomSnackbar.show(
          context,
          message: 'Verifikasi berhasil! ✓',
          backgroundColor: Colors.green,
        );

        // short delay for UX
        await Future.delayed(const Duration(milliseconds: 700));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
        );
      } else {
        final msg = (response != null && response['message'] != null)
            ? response['message']
            : 'Verifikasi gagal';
        throw msg;
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Error: $e',
        backgroundColor: Colors.red,
      );

      setState(() {
        isVerifying = false;
        shakeCount = 0;
      });
    }
  }

  Widget _buildHeader(double width) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A70A9).withOpacity(0.16),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.security_rounded,
            size: 56,
            color: Color(0xFF4A70A9),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Verifikasi Keamanan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A70A9),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Goyang HP kamu untuk membuktikan\nbahwa kamu bukan bot.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildProgressCircle(double size) {
    final progress = (shakeCount / requiredShakes).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4A70A9)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$shakeCount',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A70A9),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '/ $requiredShakes',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShakeButton() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: (isVerifying || isShaking) ? null : _startShakeDetection,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isVerifying
                ? LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF4A70A9), Color(0xFF8FABD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: isVerifying
                    ? Colors.black12
                    : const Color(0xFF4A70A9).withOpacity(0.35),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: isVerifying
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Icon(
                    isShaking ? Icons.vibration : Icons.touch_app_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVerifying)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF4A70A9)),
            ),
          if (isVerifying) const SizedBox(width: 12),
          Text(
            isVerifying
                ? 'Memverifikasi...'
                : isShaking
                    ? 'Terus goyang!'
                    : 'Ketuk untuk mulai',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A70A9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A70A9).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF4A70A9)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tips: Goyang HP dengan kuat & cepat. Pastikan device berada di tangan, bukan di meja.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final availableHeight = mq.size.height - mq.padding.top - mq.padding.bottom;
    final circleSize = min(220.0, width * 0.55);
    final progress = shakeCount / requiredShakes;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: SafeArea(
        // ✅ Proper SafeArea
        child: SingleChildScrollView(
          // ✅ ADD scroll to prevent overflow
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildHeader(width),
              const SizedBox(height: 6),
              _buildProgressCircle(circleSize),
              const SizedBox(height: 28),
              _buildShakeButton(),
              const SizedBox(height: 18),
              _buildStatusCard(),
              const SizedBox(height: 18),
              if (!isShaking && !isVerifying) _buildTips(),
              const Spacer(),
              // small hint at bottom
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 6),
                child: Text(
                  'Progress akan otomatis tersimpan selama verifikasi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
