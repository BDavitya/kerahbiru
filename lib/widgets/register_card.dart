import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../utils/encryption_helper.dart';
import '../utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/shake_verification_page.dart';

class RegisterCard extends StatefulWidget {
  final VoidCallback onSwitch;
  const RegisterCard({super.key, required this.onSwitch});

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showPassword1 = false;
  bool showPassword2 = false;
  bool isLoading = false;

  Future<void> _validateAndRegister() async {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Semua kolom wajib diisi!',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!emailController.text.contains('@')) {
      CustomSnackbar.show(
        context,
        message: 'Format email tidak valid!',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackbar.show(
        context,
        message: 'Kata sandi tidak cocok!',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final encryptedPassword = EncryptionHelper.encryptPassword(
        passwordController.text,
      );

      final response = await ApiService.register(
        name: usernameController.text,
        email: emailController.text,
        password: encryptedPassword,
      );

      if (response['success'] == true) {
        if (mounted) {
          // Simpan token dan user ID
          await SessionManager.saveLoginTime();
          if (response['user'] != null && response['user']['id'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', response['user']['id']);
            await prefs.setString('auth_token', response['token']);
          }

          CustomSnackbar.show(
            context,
            message: 'Registrasi berhasil! Lakukan verifikasi keamanan.',
            backgroundColor: Colors.green,
          );

          // Redirect ke shake verification
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ShakeVerificationPage()),
          );
        }
      } else {
        throw response['message'] ?? 'Registrasi gagal';
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
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Buat Akun di ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                  fontFamily: 'Poppins',
                ),
              ),
              Image.asset('assets/images/Icon.png', width: 40, height: 40),
              Text(
                " KerahBiru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3a6192),
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                " !",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Isi data berikut dengan lengkap untuk mendaftar",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: "Nama Lengkap",
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: !showPassword1,
            decoration: InputDecoration(
              labelText: "Kata Sandi",
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword1
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF4A70A9),
                ),
                onPressed: () => setState(() => showPassword1 = !showPassword1),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirmPasswordController,
            obscureText: !showPassword2,
            decoration: InputDecoration(
              labelText: "Ulangi Kata Sandi",
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword2
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF4A70A9),
                ),
                onPressed: () => setState(() => showPassword2 = !showPassword2),
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A70A9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isLoading ? null : _validateAndRegister,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      "Daftar",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.onSwitch,
            child: const Text.rich(
              TextSpan(
                text: "Sudah punya akun? ",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: "Masuk disini",
                    style: TextStyle(
                      color: Color(0xFF4A70A9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
