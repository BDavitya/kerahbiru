import 'package:flutter/material.dart';
import 'detail/profile_edit_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionTitle("Pengaturan"),
                  _buildSettingItem(
                    icon: Icons.attach_money_rounded,
                    title: "Mata Uang",
                    subtitle: "IDR (Rp)",
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.access_time_rounded,
                    title: "Zona Waktu",
                    subtitle: "Asia/Jakarta (WIB)",
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle("Tentang"),
                  _buildSettingItem(
                    icon: Icons.info_outline_rounded,
                    title: "Tentang Developer",
                    onTap: () => _showDevDialog(context),
                  ),

                  const SizedBox(height: 40),
                  _buildLogout(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 25, bottom: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage("assets/images/user.jpg"),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "John Doe",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Bergabung pada:",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          // ✅ BUTTON EDIT
          Positioned(
            top: 18,
            right: 18,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF4A70A9)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfilePage(), // ✅ here
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ✅ ITEM SETTING
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Function() onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          leading: Icon(icon, color: Color(0xFF4A70A9)),
          title: Text(title),
          subtitle: subtitle != null
              ? Text(subtitle, style: TextStyle(color: Colors.grey))
              : null,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 0),
      ],
    );
  }

  // ✅ BUTTON LOGOUT
  Widget _buildLogout(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showLogoutConfirm(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Logout",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  // ✅ MODAL LOGOUT CONFIRMATION
  void _showLogoutConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Konfirmasi Logout",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                "Apakah kamu yakin ingin logout dan mengakhiri sesi ini?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Logout function
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ MODAL ABOUT DEV
  void _showDevDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Tentang Developer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/dev.jpg"),
            ),
            const SizedBox(height: 10),
            const Text(
              "Barita Davitya Setiawati",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("Sistem Informasi"),
            const SizedBox(height: 10),
            const Text(
              "Kesan & Pesan: \nSemoga aplikasi ini dapat membantu banyak orang!",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text("Terima kasih telah menggunakan aplikasi ini 🌿"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
