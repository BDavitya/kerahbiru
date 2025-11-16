import 'package:flutter/material.dart';
import 'package:kerahbiru/utils/session_checker.dart';
import '../../services/api_service.dart';
import '../../utils/session_manager.dart';
import '../auth_page.dart';
import 'detail/profile_edit_page.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/user_preferences.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Pastikan setState hanya dipanggil jika widget masih terpasang
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true && mounted) {
        setState(() {
          userData = response['user'];
        });
      }
    } catch (e) {
      // Menggunakan print untuk debugging
      print('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // 1. TAMBAH: Method _showCurrencyDialog
  void _showCurrencyDialog() {
    final currencies = ['IDR', 'USD', 'EUR', 'SGD', 'MYR'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Mata Uang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return ListTile(
              title: Text(currency),
              trailing: userData?['preferred_currency'] == currency
                  ? const Icon(Icons.check, color: Color(0xFF4A70A9))
                  : null,
              onTap: () async {
                Navigator.pop(context);

                try {
                  final response = await ApiService.updatePreferences(
                    currency: currency,
                  );

                  if (response['success'] == true) {
                    // ✅ Simpan ke local storage
                    await UserPreferences.setCurrency(currency);

                    CustomSnackbar.show(
                      context,
                      message: 'Mata uang berhasil diubah menjadi $currency',
                      backgroundColor: Colors.green,
                    );
                    _loadProfile();

                    // ✅ Trigger reload halaman lain
                    setState(() {});
                  }
                } catch (e) {
                  CustomSnackbar.show(
                    context,
                    message: 'Error: $e',
                    backgroundColor: Colors.red,
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 2. TAMBAH: Method _showTimezoneDialog
  void _showTimezoneDialog() {
    final timezones = {
      'Asia/Jakarta': 'WIB (UTC+7)',
      'Asia/Makassar': 'WITA (UTC+8)',
      'Asia/Jayapura': 'WIT (UTC+9)',
      'America/New_York': 'EST (UTC-5)',
      'Europe/London': 'GMT (UTC+0)',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Zona Waktu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: timezones.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                subtitle: Text(entry.key, style: const TextStyle(fontSize: 12)),
                trailing: userData?['preferred_timezone'] == entry.key
                    ? const Icon(Icons.check, color: Color(0xFF4A70A9))
                    : null,
                onTap: () async {
                  Navigator.pop(context);

                  try {
                    final response = await ApiService.updatePreferences(
                      timezone: entry.key,
                    );

                    if (response['success'] == true) {
                      // ✅ Simpan ke local storage
                      await UserPreferences.setTimezone(entry.key);

                      CustomSnackbar.show(
                        context,
                        message: 'Zona waktu berhasil diubah',
                        backgroundColor: Colors.green,
                      );
                      _loadProfile();
                    }
                  } catch (e) {
                    CustomSnackbar.show(
                      context,
                      message: 'Error: $e',
                      backgroundColor: Colors.red,
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle("Pengaturan"),

                // 3. UPDATE: Panggilan Mata Uang
                _buildSettingItem(
                  icon: Icons.attach_money_rounded,
                  title: "Mata Uang",
                  subtitle: userData?['preferred_currency'] ?? "IDR (Rp)",
                  onTap: () => _showCurrencyDialog(), // ❗ Fungsi baru
                ),

                // 4. UPDATE: Panggilan Zona Waktu
                _buildSettingItem(
                  icon: Icons.access_time_rounded,
                  title: "Zona Waktu",
                  subtitle:
                      userData?['preferred_timezone'] ?? "Asia/Jakarta (WIB)",
                  onTap: () => _showTimezoneDialog(), // ❗ Fungsi baru
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
                const SizedBox(
                    height: 20), // Tambahkan sedikit padding di bawah
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
      ),
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
              CircleAvatar(
                radius: 45,
                // ✅ Tambahkan key untuk force refresh
                key: ValueKey(userData?['photo'] ?? 'default'),
                backgroundImage: userData?['photo'] != null
                    ? NetworkImage(
                        'http://192.168.18.37:8000/storage/${userData!["photo"]}?t=${DateTime.now().millisecondsSinceEpoch}' // ✅ Tambahkan timestamp
                        )
                    : const AssetImage("assets/images/user.jpg")
                        as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?['name'] ?? "User",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData?['email'] ?? "",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF4A70A9)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ).then((_) {
                  // ✅ Force reload setelah edit
                  setState(() => isLoading = true);
                  _loadProfile();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

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
          leading: Icon(icon, color: const Color(0xFF4A70A9)),
          title: Text(title),
          subtitle: subtitle != null
              ? Text(subtitle, style: const TextStyle(color: Colors.grey))
              : null,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 0),
      ],
    );
  }

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
                      onPressed: () async {
                        Navigator.pop(context); // Tutup dialog

                        await ApiService.logout();
                        await SessionManager.clearSession();
                        SessionChecker.stopChecking(); // ✅ Stop checker

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthPage()),
                            (route) => false,
                          );

                          // ✅ Tampilkan snackbar di halaman login
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Berhasil logout'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          });
                        }
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

  void _showDevDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Tentang Developer"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/dev.jpg"),
            ),
            SizedBox(height: 10),
            Text(
              "Barita Davitya Setiawati",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Sistem Informasi"),
            SizedBox(height: 10),
            Text(
              "Kesan & Pesan: \nSemoga aplikasi ini dapat membantu banyak orang!",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text("Terima kasih telah menggunakan aplikasi ini 🌿"),
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
