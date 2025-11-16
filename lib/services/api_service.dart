import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔧 GANTI URL INI DENGAN URL LARAVEL KAMU
  static const String baseUrl = 'http://192.168.18.37:8000/api'; // ✅ GANTI IP

  // Helper buat ambil token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Helper buat simpan token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Helper buat hapus token (logout)
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Helper untuk simpan user ID
  static Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // ========== AUTH ENDPOINTS ==========

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      print('Register Response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response: ${response.body}');
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await _saveToken(data['token']);
        await _saveUserId(data['user']['id']);
      }

      return data;
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _clearToken();
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }

  static Future<Map<String, dynamic>> completeProfile({
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/complete-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phone': phone,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========== USER ENDPOINTS ==========

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.get(
        Uri.parse('$baseUrl/profile?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    File? photo,
  }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/update'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['user_id'] = userId.toString();

      if (name != null) request.fields['name'] = name;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;

      if (photo != null) {
        request.files
            .add(await http.MultipartFile.fromPath('photo', photo.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========== WORKER ENDPOINTS ==========

  static Future<Map<String, dynamic>> getWorkers({
    String? search,
    String? gender,
    String? sortBy,
  }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      var uri = Uri.parse('$baseUrl/workers');

      Map<String, String> queryParams = {'user_id': userId.toString()};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (gender != null && gender != 'Semua') queryParams['gender'] = gender;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Workers Response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Workers error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getWorkerDetail(int workerId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/workers/$workerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========== ORDER ENDPOINTS ==========

  static Future<Map<String, dynamic>> createOrder({
    required int workerId,
    required String orderDate,
    required String timeSlot,
  }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'worker_id': workerId,
          'order_date': orderDate,
          'time_slot': timeSlot,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.get(
        Uri.parse('$baseUrl/orders?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Orders Response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Orders error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadPhotoBefore({
    required int orderId,
    required File photo,
  }) async {
    try {
      final token = await _getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/orders/$orderId/photo-before'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadPhotoAfter({
    required int orderId,
    required File photo,
  }) async {
    try {
      final token = await _getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/orders/$orderId/photo-after'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required int orderId,
    required double rating,
    String? review,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/review'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'review': review,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========== GAMIFICATION ENDPOINTS ==========

  static Future<Map<String, dynamic>> shakeForPoints() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/shake'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getGamificationStatus() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.get(
        Uri.parse('$baseUrl/gamification/status?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserVouchers() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.get(
        Uri.parse('$baseUrl/vouchers?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePreferences({
    String? currency,
    String? timezone,
  }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/profile/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          if (currency != null) 'preferred_currency': currency,
          if (timezone != null) 'preferred_timezone': timezone,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyShakeCaptcha() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      final response = await http.post(
        Uri.parse('$baseUrl/verify-shake'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
