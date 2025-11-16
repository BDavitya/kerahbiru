import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../utils/favorite_database.dart';
import '../order_page.dart';
import '../../../utils/timezone_helper.dart';
import '../../../utils/user_preferences.dart';

class WorkerDetailPage extends StatefulWidget {
  final Map<String, dynamic> worker;

  const WorkerDetailPage({super.key, required this.worker});

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _loadTimezone();
  }

  Future<void> _checkFavorite() async {
    final result = await FavoriteDatabase.isFavorite(widget.worker['id']);
    setState(() => isFavorite = result);
  }

  Future<void> _loadTimezone() async {
    final tz = await UserPreferences.getTimezone();
    setState(() => currentTimezone = tz);
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await FavoriteDatabase.removeFavorite(widget.worker['id']);
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Dihapus dari favorit.',
          backgroundColor: Colors.red,
        );
      }
    } else {
      await FavoriteDatabase.addFavorite(widget.worker);
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Ditambahkan ke favorit!',
          backgroundColor: Colors.green,
        );
      }
    }
    setState(() => isFavorite = !isFavorite);
  }

  String formatRupiah(dynamic harga) {
    final number = (harga is num)
        ? harga.toInt()
        : int.tryParse(harga.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  Future<void> _openWhatsApp() async {
    final worker = widget.worker;
    final phone = worker['whatsapp'] ?? worker['phone'] ?? '';
    final name = worker['name'] ?? '';

    final url = Uri.parse(
        'https://wa.me/$phone?text=Halo, saya tertarik dengan jasa $name');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Tidak dapat membuka WhatsApp',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Widget _timeChip(String text) {
    final convertedTime = TimezoneHelper.convertTime(text, currentTimezone);

    return Chip(
      label: Text(
        convertedTime,
        style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF4A70A9), width: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                expandedHeight: 250,
                leading: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF4A70A9),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: worker["photo"] != null
                      ? ClipRRect(
                          child: Image.network(
                            'http://192.168.1.5:8000/storage/${worker["photo"]}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 60),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 60),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker["name"]?.toString() ?? "Pekerja",
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  worker["job_title"]?.toString() ?? "-",
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatRupiah(worker["price_per_hour"]),
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4A70A9),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFF4A70A9),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${worker["distance"]?.toString() ?? '0'} km",
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      Text(
                        worker["description"]?.toString() ??
                            "Pekerja profesional dengan pengalaman luas dan hasil kerja berkualitas tinggi. Siap membantu Anda dengan layanan terbaik!",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        "Waktu Tersedia (WIB)",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _timeChip("08:00 - 10:00"),
                          _timeChip("10:00 - 12:00"),
                          _timeChip("13:00 - 15:00"),
                          _timeChip("15:00 - 17:00"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text(
                        "Ulasan Pelanggan",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${worker["rating"]?.toString() ?? '0'} dari 5.0",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "(${worker["total_orders"]?.toString() ?? '0'} order)",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _reviewCard(
                        "Siti Aisyah",
                        "Kerjanya cepat dan hasilnya rapi banget, recommended!",
                        4.5,
                      ),
                      _reviewCard(
                        "Dodi",
                        "Pelayanan bagus dan tepat waktu. Pasti order lagi!",
                        4.0,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color:
                            isFavorite ? Colors.red : const Color(0xFF4A70A9),
                      ),
                      label: const Text("Favorit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A70A9),
                        side: const BorderSide(color: Color(0xFF4A70A9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPage(worker: worker),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_rounded),
                      label: const Text("Pesan Sekarang"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A70A9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _timeChip(String text) => Chip(
        label: Text(
          text,
          style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF4A70A9), width: 0.5),
      );

  Widget _reviewCard(String name, String comment, double rating) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              comment,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}
