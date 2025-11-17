import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/session/session_manager.dart';
import '../../utils/session/session_checker.dart';
import '../../utils/helpers/image_helper.dart';
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
      debugPrint('❌ Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showCurrencyDialog() {
    final currencies = ['IDR', 'USD', 'EUR', 'SGD', 'MYR', 'JPY'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Pilih Mata Uang',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            final isSelected = userData?['preferred_currency'] == currency;
            return ListTile(
              title: Text(
                currency,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF4A70A9))
                  : null,
              onTap: () async {
                Navigator.pop(context);

                try {
                  // ✅ 1. Update local first (instant feedback)
                  await UserPreferences.setCurrency(currency);

                  // ✅ 2. Update API (background)
                  ApiService.updatePreferences(currency: currency)
                      .then((response) {
                    if (response['success'] == true) {
                      print('✅ Currency synced to API');
                    }
                  });

                  if (mounted) {
                    // ✅ 3. Show success & reload
                    CustomSnackbar.show(
                      context,
                      message: 'Mata uang diubah ke $currency',
                      backgroundColor: Colors.green,
                    );

                    await _loadProfile();
                  }
                } catch (e) {
                  if (mounted) {
                    CustomSnackbar.show(
                      context,
                      message: 'Error: $e',
                      backgroundColor: Colors.red,
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Pilih Zona Waktu',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: timezones.entries.map((entry) {
              final isSelected = userData?['preferred_timezone'] == entry.key;
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4A70A9))
                    : null,
                onTap: () async {
                  Navigator.pop(context);

                  try {
                    // ✅ 1. Update local first
                    await UserPreferences.setTimezone(entry.key);

                    // ✅ 2. Update API (background)
                    ApiService.updatePreferences(timezone: entry.key)
                        .then((response) {
                      if (response['success'] == true) {
                        print('✅ Timezone synced to API');
                      }
                    });

                    if (mounted) {
                      // ✅ 3. Show success & reload
                      CustomSnackbar.show(
                        context,
                        message: 'Zona waktu diubah',
                        backgroundColor: Colors.green,
                      );

                      await _loadProfile();
                    }
                  } catch (e) {
                    if (mounted) {
                      CustomSnackbar.show(
                        context,
                        message: 'Error: $e',
                        backgroundColor: Colors.red,
                      );
                    }
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
                _buildSettingItem(
                  icon: Icons.attach_money_rounded,
                  title: "Mata Uang",
                  subtitle: userData?['preferred_currency'] ?? "IDR (Rp)",
                  onTap: _showCurrencyDialog,
                ),
                _buildSettingItem(
                  icon: Icons.access_time_rounded,
                  title: "Zona Waktu",
                  subtitle:
                      userData?['preferred_timezone'] ?? "Asia/Jakarta (WIB)",
                  onTap: _showTimezoneDialog,
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
                const SizedBox(height: 20),
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
              // ✅ FIXED: Gunakan ImageHelper
              CircleAvatar(
                radius: 45,
                key: ValueKey(userData?['photo'] ?? 'default'),
                backgroundImage: ImageHelper.getNetworkImage(
                  userData?['photo'],
                  defaultAsset: "assets/images/user.jpg",
                ),
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
                        Navigator.pop(context);

                        await ApiService.logout();
                        await SessionManager.clearSession();
                        SessionChecker.stopChecking();

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthPage()),
                            (route) => false,
                          );

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
