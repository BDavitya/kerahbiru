import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // untuk format harga
import '../../../widgets/custom_snackbar.dart';
import '../order_page.dart';

class WorkerDetailPage extends StatefulWidget {
  final Map<String, dynamic> worker;

  const WorkerDetailPage({super.key, required this.worker});

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  bool isFavorite = false;

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

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // AppBar dengan tombol kembali
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
                  background: ClipRRect(
                    child: Image.asset(
                      worker["foto"].toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Konten
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama, pekerjaan, harga, dan jarak
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kolom kiri (nama dan pekerjaan)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker["nama"]?.toString() ?? "Pekerja",
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  worker["pekerjaan"]?.toString() ?? "-",
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Kolom kanan (harga dan jarak)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatRupiah(worker["harga"]),
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
                                    worker["jarak"]?.toString() ?? "0 km",
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

                      // Deskripsi
                      Text(
                        worker["deskripsi"]?.toString() ??
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

                      // Jadwal
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

                      // Rating & Ulasan
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
                            "(${worker["order"]?.toString() ?? '0'} order)",
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
                        "(4/5) Kerjanya cepat dan hasilnya rapi banget, recommended!",
                      ),
                      _reviewCard(
                        "Dodi",
                        "(3/5) Pelayanan bagus dan tepat waktu. Pasti order lagi!",
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Buttons
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
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        CustomSnackbar.show(
                          context,
                          message: isFavorite
                              ? 'Ditambahkan ke favorit!'
                              : 'Dihapus dari favorit.',
                          backgroundColor: isFavorite
                              ? Colors.green
                              : Colors.red,
                        );
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? Colors.red
                            : const Color(0xFF4A70A9),
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
                            builder: (context) => OrderPage(
                              workerName: "Siti Rahmawati",
                              jobTitle: "Asisten Rumah Tangga",
                              pricePerKm: 20000,
                              distance: 4.2,
                              availableSessions: {
                                "Senin": ["08.00–10.00", "13.00–15.00"],
                                "Selasa": ["09.00–11.00", "14.00–16.00"],
                                "Kamis": ["10.00–12.00", "15.00–17.00"],
                              },
                            ),
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
}

// 🔹 Widget Tambahan
Widget _timeChip(String text) => Chip(
  label: Text(
    text,
    style: const TextStyle(fontFamily: "Poppins", fontSize: 12),
  ),
  backgroundColor: Colors.white,
  side: const BorderSide(color: Color(0xFF4A70A9), width: 0.5),
);

Widget _reviewCard(String name, String comment) => Container(
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
      Text(
        name,
        style: const TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
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
