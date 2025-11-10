import 'package:flutter/material.dart';
import 'dart:async';

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = const Color(0xFF4A70A9),
    Duration duration = const Duration(seconds: 5),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(fadeAnimation),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    animationController.forward();

    Timer(duration, () async {
      await animationController.reverse();
      overlayEntry.remove();
      animationController.dispose();
    });
  }
}
