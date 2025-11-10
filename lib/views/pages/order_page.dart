import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../widgets/custom_snackbar.dart';
import '../home_page.dart';

class OrderPage extends StatefulWidget {
  final String workerName;
  final String jobTitle;
  final double pricePerKm;
  final double distance;
  final Map<String, List<String>>
  availableSessions; // contoh: {"Senin": ["08.00-10.00", "13.00-15.00"]}

  const OrderPage({
    super.key,
    required this.workerName,
    required this.jobTitle,
    required this.pricePerKm,
    required this.distance,
    required this.availableSessions,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  DateTime? selectedDate;
  String? selectedSession;

  List<String> getAvailableSessionsForSelectedDay() {
    if (selectedDate == null) return [];
    final hari = DateFormat('EEEE', 'id_ID').format(selectedDate!);
    return widget.availableSessions[hari] ?? [];
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.pricePerKm * 2;
    final sesiList = getAvailableSessionsForSelectedDay();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(
            color: Color(0xFF4A70A9),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leadingWidth: 64,
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
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              widget.workerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(widget.jobTitle, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),

            // Pilih tanggal
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: const Text(
                  "Tanggal Tersedia",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    selectedDate == null
                        ? "Belum dipilih"
                        : DateFormat(
                            'EEEE, dd MMM yyyy',
                            'id_ID',
                          ).format(selectedDate!),
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 14)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      selectedSession = null; // reset sesi saat tanggal berubah
                    });
                  }
                },
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: const Text(
                  "Pilih Sesi Tersedia",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: sesiList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Tidak ada sesi tersedia untuk tanggal ini",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: sesiList
                              .map(
                                (sesi) => ChoiceChip(
                                  label: Text(sesi),
                                  selected: selectedSession == sesi,
                                  selectedColor: Colors.blueGrey,
                                  labelStyle: TextStyle(
                                    color: selectedSession == sesi
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onSelected: (_) {
                                    setState(() {
                                      selectedSession = sesi;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),
            ),

            const Spacer(),

            // Info harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Jarak Pekerja"),
                Text("${widget.distance.toStringAsFixed(1)} km"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Harga",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${total.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),

      // Tombol bawah
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF4A70A9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text("Konfirmasi Pesanan"),
            onPressed: () {
              if (selectedDate == null) {
                CustomSnackbar.show(
                  context,
                  message: "Pilih tanggal terlebih dahulu",
                  backgroundColor: Colors.red,
                );
              } else if (selectedSession == null) {
                CustomSnackbar.show(
                  context,
                  message: "Pilih sesi waktu terlebih dahulu",
                  backgroundColor: Colors.red,
                );
              } else {
                CustomSnackbar.show(
                  context,
                  message:
                      "Pesanan dikonfirmasi untuk ${DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(selectedDate!)} sesi $selectedSession",
                  backgroundColor: Colors.green,
                );

                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
