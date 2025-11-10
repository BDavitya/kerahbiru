import 'package:flutter/material.dart';
import '../../widgets/custom_snackbar.dart';
import 'detail/worker_detail_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  String selectedFilter = "Semua";
  bool isLoading = false;

  // 💡 Gunakan final untuk data statis
  final List<Map<String, dynamic>> workers = [
    {
      "nama": "Budi Santoso",
      "pekerjaan": "Tukang Bangunan",
      "rating": 4.8,
      "jarak": 3.2,
      "harga": 75000,
      "gender": "Laki-Laki",
      "foto": "assets/images/Worker1.png",
      "favorite": false,
      "order": 120, // 🛠️ DITAMBAHKAN: Field 'order' yang hilang
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
      "order": 95, // 🛠️ DITAMBAHKAN: Field 'order' yang hilang
    },
    {
      "nama": "Andi Wijaya",
      "pekerjaan": "Tukang Las",
      "rating": 4.9,
      "jarak": 4.1,
      "harga": 110000,
      "gender": "Laki-Laki",
      "foto": "assets/images/Worker3.png",
      "favorite": false,
      "order": 150, // 🛠️ DITAMBAHKAN: Field 'order' yang hilang
    },
    {
      "nama": "Siti Aulia",
      "pekerjaan": "Asisten Rumah Tangga",
      "rating": 4.7,
      "jarak": 2.8,
      "harga": 60000,
      "gender": "Perempuan",
      "foto": "assets/images/Worker4.png",
      "favorite": false,
      "order": 200, // 🛠️ DITAMBAHKAN: Field 'order' yang hilang
    },
  ];

  // 💡 Perbaikan: Logika favorit yang diperbarui
  void _toggleFavorite(int workerIndex) {
    // Cari index pekerja di list workers asli menggunakan data di filteredWorkers
    // 💡 Menggunakan hasil filter saat ini, bukan index dari list 'workers' asli.
    final currentWorker = filteredWorkers[workerIndex];

    final originalIndex = workers.indexWhere(
      (worker) => worker["nama"] == currentWorker["nama"],
    );

    if (originalIndex != -1) {
      final worker = workers[originalIndex];
      final isFavorite = worker["favorite"] as bool;
      setState(() {
        // Memperbarui list pekerja asli
        workers[originalIndex]["favorite"] = !isFavorite;

        // Memastikan filteredWorkers diperbarui secara otomatis melalui getter
        // tidak perlu diubah secara eksplisit di sini.
      });

      if (!isFavorite) {
        CustomSnackbar.show(
          context,
          message: 'Berhasil menambahkan ${worker["nama"]} ke favorit!',
          backgroundColor: Colors.green,
        );
      } else {
        CustomSnackbar.show(
          context,
          message: "Menghapus ${worker["nama"]} dari favorit.",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredWorkers {
    // Salin list agar tidak mengubah data asli, tapi menggunakan list asli
    List<Map<String, dynamic>> results = List.from(workers);

    // Filter pencarian
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results.where((worker) {
        return (worker["nama"] as String).toLowerCase().contains(q) ||
            (worker["pekerjaan"] as String).toLowerCase().contains(q);
      }).toList();
    }

    // Filter kategori
    switch (selectedFilter) {
      case "Perempuan":
        results = results.where((w) => w["gender"] == "Perempuan").toList();
        break;
      case "Laki-Laki":
        results = results.where((w) => w["gender"] == "Laki-Laki").toList();
        break;
      case "Termurah":
        // Pastikan tipe data benar sebelum membandingkan
        results.sort(
          (a, b) => (a["harga"] as num).compareTo(b["harga"] as num),
        );
        break;
      case "Terdekat":
        results.sort(
          (a, b) => (a["jarak"] as num).compareTo(b["jarak"] as num),
        );
        break;
      case "Terpercaya":
        results.sort(
          (a, b) => (b["rating"] as num).compareTo(a["rating"] as num),
        );
        break;
      default:
        break; // “Semua” tidak filter apa pun
    }

    return results;
  }

  void changeFilter(String filter) async {
    // Jika filter yang dipilih sama, tidak perlu memuat ulang
    if (selectedFilter == filter) return;

    setState(() {
      selectedFilter = filter;
      isLoading = true;
    });

    // simulasi loading biar ada efek transisi smooth
    await Future.delayed(const Duration(milliseconds: 450));

    setState(() {
      isLoading = false;
    });
  }

  // 💡 Fungsi untuk memformat harga
  String _formatCurrency(int amount) {
    // Contoh sederhana: Menambahkan "Rp" dan memformat ribuan (perlu package intl untuk format yang lebih baik)
    final String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final workersToDisplay = filteredWorkers; // Ambil hasilnya sekali saja

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: _buildSearchBar(),
        automaticallyImplyLeading: false, // hilangkan tombol back default
      ),

      backgroundColor: const Color(0xFFEFECE3),
      body: SafeArea(
        child: Column(
          children: [
            // Sapaan user
            _buildGreeting(),

            // Submenu filter kategori
            _buildFilterChips(),

            const SizedBox(height: 10),

            // Daftar pekerja
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: workersToDisplay
                      .length, // 💡 Menggunakan workersToDisplay
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final worker = workersToDisplay[index];
                    return _buildWorkerCard(
                      worker,
                      index,
                    ); // 🛠️ Menggunakan widget yang diekstrak dan diperbaiki
                  },
                ),
              ),
            ),
            const SizedBox(height: 16), // Padding bawah
          ],
        ),
      ),
    );
  }

  // 💡 Ekstraksi Widget: Search Bar (Tidak diubah)
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => setState(() => searchQuery = val),
      decoration: InputDecoration(
        hintText: "Cari pekerja...",
        hintStyle: const TextStyle(fontFamily: "Poppins"),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF4A70A9)),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 💡 Ekstraksi Widget: Greeting (Tidak diubah)
  Widget _buildGreeting() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Selanat Datang, Bar!", // Ganti dengan nama user yang sebenarnya
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // 💡 Ekstraksi Widget: Filter Chips (Tidak diubah)
  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          _buildFilterChip("Semua", Icons.grid_view_rounded),
          _buildFilterChip("Perempuan", Icons.woman_rounded),
          _buildFilterChip("Laki-Laki", Icons.man_rounded),
          _buildFilterChip("Termurah", Icons.attach_money_rounded),
          _buildFilterChip("Terdekat", Icons.location_on_rounded),
          _buildFilterChip("Terpercaya", Icons.star_rounded),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  // 💡 Ekstraksi Widget: Single Filter Chip (Tidak diubah)
  Widget _buildFilterChip(String label, IconData icon) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () => changeFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A70A9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A70A9)
                : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A70A9).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF4A70A9),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 Ekstraksi Widget: Worker Card (DIPERBAIKI)
  Widget _buildWorkerCard(Map<String, dynamic> worker, int index) {
    // 🛠️ PERBAIKAN: Format harga di sini.
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
                          // 🛠️ PERBAIKAN: Memastikan worker["rating"] dipanggil dengan benar
                          Text(
                            "${worker["rating"]} | ${worker["order"]}x", // 💡 Menggunakan field 'order' yang sudah ditambahkan
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
                            // 🛠️ PERBAIKAN: Memastikan worker["jarak"] dipanggil dengan benar
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
                        "$formattedHarga/jam", // Menggunakan format yang diperbaiki
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

            // Favorite button
            Positioned(
              bottom: 10,
              right: 10,
              // 🛠️ Menggunakan index dari filteredWorkers
              child: GestureDetector(
                onTap: () => _toggleFavorite(index),
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
                  child: Icon(
                    worker["favorite"]
                            as bool // Pastikan casting ke bool
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: worker["favorite"] as bool
                        ? Colors.red
                        : const Color(0xFF4A70A9),
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
