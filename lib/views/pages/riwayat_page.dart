import 'package:flutter/material.dart';
import 'detail/order_detail_page.dart';
import '../../../models/riwayat.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Riwayat> riwayatList = [
      Riwayat(
        nama: "Budi Santoso",
        pekerjaan: "Tukang Bangunan",
        tanggal: "10 Nov 2025",
        durasi: "09.00 - 15.00",
        harga: 150000,
        status: "Selesai",
        foto: "assets/images/Worker1.png",
        rating: 4.8,
      ),
      Riwayat(
        nama: "Rina Putri",
        pekerjaan: "Tukang Listrik",
        tanggal: "11 Nov 2025",
        durasi: "13.00 - 17.00",
        harga: 120000,
        status: "Dalam Proses",
        foto: "assets/images/Worker2.png",
        rating: 4.7,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: riwayatList.length,
          itemBuilder: (context, index) {
            final r = riwayatList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailRiwayatPage(riwayat: r),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto pekerja
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(r.foto),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Info pesanan
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          right: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    r.nama,
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: r.status == "Selesai"
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    r.status,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: r.status == "Selesai"
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                            Text(
                              r.pekerjaan,
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              // 🔹 Gabungan tanggal dan sesi
                              "${r.tanggal}, ${r.durasi}",
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 8),
                            Text(
                              "Rp${r.harga.toString()}",
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A70A9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
