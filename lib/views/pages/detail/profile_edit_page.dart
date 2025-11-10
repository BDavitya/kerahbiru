import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController nameC = TextEditingController(text: "John Doe");
  final TextEditingController emailC = TextEditingController(
    text: "johndoe@email.com",
  );
  final TextEditingController phoneC = TextEditingController(
    text: "089123456789",
  );
  final TextEditingController addressC = TextEditingController(text: "Jakarta");

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECE3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF4A70A9),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 10),

          // FOTO PROFILE
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : const AssetImage("assets/images/user.jpg")
                            as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A70A9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildField(label: "Nama", controller: nameC),
          _buildField(
            label: "Email",
            controller: emailC,
            keyboard: TextInputType.emailAddress,
          ),
          _buildField(
            label: "No. HP",
            controller: phoneC,
            keyboard: TextInputType.phone,
          ),
          _buildField(label: "Alamat", controller: addressC, maxLines: 2),

          const SizedBox(height: 25),
          _saveBtn(context),
        ],
      ),
    );
  }

  // INPUT FIELD
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON SIMPAN
  Widget _saveBtn(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A70A9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () {
        // TODO: save to backend
        Navigator.pop(context);
      },
      child: const Text(
        "Simpan",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
