import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';

class AuthService {
  final String baseUrl = "https://api.isc-webdev.my.id/api/v1";

  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login'); // Disesuaikan dengan web

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authData = AuthResponse.fromJson(responseBody);
        await _saveToken(authData.token);
        await _saveUserData(authData.user); // Simpan data user lokal
        return authData;
      } else {
        throw Exception(responseBody['message'] ?? 'Login gagal. Periksa email dan password.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<AuthResponse> register(String name, String email, String password, String passwordConfirmation) async {
    final url = Uri.parse('$baseUrl/auth/signup'); // Disesuaikan dengan web

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
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
        throw Exception(responseBody['message'] ?? 'Registrasi gagal.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Memanggil API logout agar sesi di server (backend) juga terhapus persis seperti web
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        // Abaikan error jaringan saat logout, yang penting token lokal dihapus
      }
    }

    // Hapus data dari memori HP
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  // Mengambil data user yang tersimpan di HP
  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Guest',
      'email': prefs.getString('user_email') ?? '',
      'role': prefs.getString('user_role') ?? 'customer',
    };
  }

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