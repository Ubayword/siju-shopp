import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';

class AuthService {
  final String baseUrl = "https://api.isc-webdev.my.id/api/v1";

  // ---------------------------------------------------------
  // FUNGSI HELPER: Menerjemahkan Error Laravel ke Bahasa Indonesia
  // ---------------------------------------------------------
  String _mapLaravelError(String errorMsg) {
    if (errorMsg.contains('validation.required')) return 'Kolom ini wajib diisi/dikirim.';
    if (errorMsg.contains('validation.unique')) return 'Data ini sudah terdaftar.';
    if (errorMsg.contains('validation.email')) return 'Format email tidak valid.';
    if (errorMsg.contains('validation.min.string')) return 'Terlalu pendek.';
    if (errorMsg.contains('validation.confirmed')) return 'Konfirmasi tidak cocok.';
    return errorMsg;
  }

  // ---------------------------------------------------------
  // FUNGSI LOGIN
  // ---------------------------------------------------------
  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({
          'username': username, // Diubah dari email ke username
          'password': password
        }),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authData = AuthResponse.fromJson(responseBody);
        await _saveToken(authData.token);
        await _saveUserData(authData.user);
        return authData;
      } else {
        if (responseBody.containsKey('errors')) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          throw Exception(_mapLaravelError(errors.values.first[0].toString()));
        }
        throw Exception(responseBody['message'] ?? 'Login gagal.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // FUNGSI BARU: Mengecek apakah user sudah klik link verifikasi di email
  Future<bool> checkVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'), // Memanggil data profil diri sendiri
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Di Laravel, jika email_verified_at tidak null, berarti sudah verifikasi
        // Sesuaikan 'email_verified_at' dengan field dari API Anda
        return data['data']['email_verified_at'] != null;
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error checking status: $e");
    }
    return false;
  }

  // ---------------------------------------------------------
  // FUNGSI REGISTER (BUAT AKUN)
  // ---------------------------------------------------------
  // Tambahkan 'String phone' di parameter
  Future<AuthResponse> register(String name, String username, String email, String phone, String password, String passwordConfirmation) async {
    final url = Uri.parse('$baseUrl/auth/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'username': username,
          'email': email,
          'phone': phone, // <--- Kolom phone ditambahkan ke payload
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authData = AuthResponse.fromJson(responseBody);
        await _saveToken(authData.token);
        await _saveUserData(authData.user);
        return authData;
      } else {
        if (responseBody.containsKey('errors')) {
          final errors = responseBody['errors'];
          if (errors is Map) {
            String failedField = errors.keys.first;
            String errorMsg = errors.values.first[0].toString();
            throw Exception("Ternyata Kolom [$failedField] kurang: ${_mapLaravelError(errorMsg)}");
          } else if (errors is List) {
            throw Exception(_mapLaravelError(errors[0].toString()));
          }
        }
        throw Exception(responseBody['message'] ?? 'Registrasi gagal.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // Fungsi Verifikasi OTP (Sesuai web: POST /v1/auth/verify-otp)
  Future<void> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(responseBody['message'] ?? 'Kode OTP salah atau kadaluarsa.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // ---------------------------------------------------------
  // FUNGSI LOGOUT
  // ---------------------------------------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        );
      } catch (e) {
        // Abaikan error jaringan saat logout
      }
    }
    
    // Hapus data dari HP
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  // ---------------------------------------------------------
  // FUNGSI CEK STATUS LOGIN & AMBIL DATA
  // ---------------------------------------------------------
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Guest',
      'email': prefs.getString('user_email') ?? '',
      'role': prefs.getString('user_role') ?? 'customer',
    };
  }

  // ---------------------------------------------------------
  // FUNGSI INTERNAL (PRIVATE)
  // ---------------------------------------------------------
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserData(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role ?? 'customer');
  }
}