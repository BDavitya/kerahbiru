import 'package:flutter/material.dart';
import '../../../models/riwayat.dart';
import '../foto_before_page.dart';
import '../foto_after_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DetailRiwayatPage extends StatefulWidget {
  final Riwayat riwayat;
  const DetailRiwayatPage({super.key, required this.riwayat});

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  int progressStep =
      0; // 0: belum mulai, 1: before done, 2: after done, 3: rating done
  String? fotoBefore;
  String? fotoAfter;

  @override
  Widget build(BuildContext context) {
    final r = widget.riwayat;
    final steps = [
      "Pemesanan Diterima",
      "Sedang Menuju Lokasi",
      "Mulai Bekerja",
      "Pekerjaan Selesai",
      "Pembayaran",
      "Ulasan Diberikan",
    ];

    String buttonLabel;
    VoidCallback? onButtonPressed;

    // 🔁 Button dinamis berdasarkan progressStep
    if (progressStep == 0) {
      buttonLabel = "Mulai Bekerja";
      onButtonPressed = () async {
        final foto = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FotoBeforePage()),
        );
        if (foto != null) {
          setState(() {
            fotoBefore = foto;
            progressStep = 1;
          });
        }
      };
    } else if (progressStep == 1) {
      buttonLabel = "Pekerjaan Selesai";
      onButtonPressed = () async {
        final foto = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FotoAfterPage()),
        );
        if (foto != null) {
          setState(() {
            fotoAfter = foto;
            progressStep = 2;
          });
        }
      };
    } else if (progressStep == 2) {
      buttonLabel = "Lakukan Pembayaran";
      onButtonPressed = () {
        setState(() {
          progressStep = 3;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil ✅")));
      };
    } else if (progressStep == 3) {
      buttonLabel = "Beri Rating & Ulasan";
      onButtonPressed = () {
        _showRatingPopup(context);
      };
    } else {
      buttonLabel = "";
      onButtonPressed = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      body: CustomScrollView(
        slivers: [
          // 🔹 Header dengan SliverAppBar mirip halaman pekerja
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
              centerTitle: true,
              title: Text(
                "Detail Riwayat",
                style: const TextStyle(
                  color: Colors.black87,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              background: ClipRRect(
                child: Image.asset(r.foto, fit: BoxFit.cover),
              ),
            ),
          ),

          // 🔸 Konten
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan pekerjaan
                  Text(
                    r.nama,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    r.pekerjaan,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Tanggal dan Sesi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${r.tanggal}, ${r.durasi}",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        r.status,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: r.status == "Selesai"
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28, thickness: 0.8),

                  // Timeline progress
                  const Text(
                    "Progress Pekerjaan",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(steps.length, (i) {
                      bool done = i <= progressStep;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? const Color(0xFF4A70A9)
                                      : Colors.grey[400],
                                ),
                              ),
                              if (i < steps.length - 1)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: done
                                      ? const Color(0xFF4A70A9)
                                      : Colors.grey[300],
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                steps[i],
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 13,
                                  color: done ? Colors.black87 : Colors.black45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // Foto Before & After
                  if (fotoBefore != null || fotoAfter != null) ...[
                    const Text(
                      "Foto Bukti",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (fotoBefore != null)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                fotoBefore as dynamic,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (fotoAfter != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  fotoAfter as dynamic,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔘 Button dinamis
      bottomNavigationBar: progressStep < 4
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A70A9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onButtonPressed,
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showRatingPopup(BuildContext context) {
    double rating = 0;
    final TextEditingController ulasanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Beri Rating & Ulasan",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 34,
                unratedColor: Colors.grey[300],
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ulasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis ulasan kamu di sini...",
                  hintStyle: const TextStyle(fontFamily: "Poppins"),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A70A9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (rating > 0 && ulasanController.text.isNotEmpty) {
                      Navigator.pop(context);
                      setState(() {
                        progressStep = 4;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Terima kasih atas ulasannya! (${rating.toStringAsFixed(1)}⭐)",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mohon isi rating dan ulasan."),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Kirim",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
