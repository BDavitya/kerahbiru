import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionHelper {
  // Enkripsi password sebelum dikirim ke API
  // Menggunakan SHA-256 hash
  static String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verifikasi password (untuk keperluan lokal jika diperlukan)
  static bool verifyPassword(String password, String hashedPassword) {
    return encryptPassword(password) == hashedPassword;
  }
}
