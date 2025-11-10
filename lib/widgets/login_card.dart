import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import '../views/home_page.dart'; // nanti ganti sesuai struktur kamu

class LoginCard extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginCard({super.key, required this.onSwitch});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  void _validateAndLogin() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
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
        message: 'Format email tidak sesuai!',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Kalau semua valid:
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
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
                "Selamat Datang di ",
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
            "Masuk untuk melanjutkan",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
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
            obscureText: !showPassword,
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
                  showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF4A70A9),
                ),
                onPressed: () => setState(() => showPassword = !showPassword),
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
              onPressed: _validateAndLogin,
              child: const Text(
                "Masuk",
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
                text: "Belum punya akun? ",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: "Daftar sekarang",
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
