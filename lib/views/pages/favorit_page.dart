import 'package:flutter/material.dart';
import '../../widgets/custom_snackbar.dart';
import 'detail/worker_detail_page.dart';

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  // 🧩 Contoh data sementara — pastikan nanti kamu sync ke data global
  List<Map<String, dynamic>> workers = [
    {
      "nama": "Budi Santoso",
      "pekerjaan": "Tukang Bangunan",
      "rating": 4.8,
      "jarak": 3.2,
      "harga": 75000,
      "gender": "Laki-Laki",
      "foto": "assets/images/Worker1.png",
      "favorite": true,
      "order": 120,
    },
    {
      "nama": "Rina Putri",
      "pekerjaan": "Tukang Listrik",
      "rating": 4.6,
      "jarak": 7.5,
      "harga": 90000,
      "gender": "Perempuan",
      "foto": "assets/images/Worker2.png",
      "favorite": false,
      "order": 95,
    },
    {
      "nama": "Siti Aulia",
      "pekerjaan": "Asisten Rumah Tangga",
      "rating": 4.7,
      "jarak": 2.8,
      "harga": 60000,
      "gender": "Perempuan",
      "foto": "assets/images/Worker4.png",
      "favorite": true,
      "order": 200,
    },
  ];

  // Hanya ambil yang favorit
  List<Map<String, dynamic>> get favoriteWorkers =>
      workers.where((w) => w["favorite"] == true).toList();

  void _toggleFavorite(String namaPekerja) {
    setState(() {
      // cari di list utama
      final index = workers.indexWhere((w) => w["nama"] == namaPekerja);
      if (index != -1) {
        workers[index]["favorite"] = false;

        // ambil nama pekerja sebelum snackbar
        final workerName = workers[index]["nama"];

        // tampilkan snackbar dengan nama pekerja
        CustomSnackbar.show(
          context,
          message: "Menghapus $workerName dari favorit.",
          backgroundColor: Colors.red,
        );
      }
    });
  }

  String _formatCurrency(int amount) {
    final String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final favList = favoriteWorkers;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Pekerja Favorit",
          style: TextStyle(
            color: Color(0xFF4A70A9),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: favList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada pekerja favorit",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GridView.builder(
                itemCount: favList.length,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 260,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final worker = favList[index];
                  return _buildWorkerCard(worker, index);
                },
              ),
            ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker, int index) {
    final formattedHarga = _formatCurrency(worker["harga"] as int);
    final isTopRated = worker["rating"] >= 4.8;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkerDetailPage(worker: worker)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Image.asset(
                    worker["foto"],
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              worker["nama"],
                              style: const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isTopRated)
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF4A70A9),
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker["pekerjaan"],
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "${worker["rating"]} | ${worker["order"]}x",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF8FABD4),
                            size: 16,
                          ),
                          Text(
                            "${worker["jarak"]} km",
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$formattedHarga/jam",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A70A9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Tombol Unfavorite ❤️
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _toggleFavorite(worker["nama"]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
