import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = "https://api.isc-webdev.my.id/api/v1";

  Future<List<ProductData>> getProducts({String? search}) async {
    // Jika ada kata kunci pencarian, tambahkan query string ke URL
    String urlString = '$baseUrl/products';
    if (search != null && search.isNotEmpty) {
      urlString += '?search=$search'; // Sesuaikan query param dengan API backend Anda
    }
    
    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonBody = json.decode(response.body);
          return ProductListResponse.fromJson(jsonBody).data;
        } catch (e) {
          throw Exception("Gagal membaca data. Server mengembalikan format yang salah.");
        }
      } else {
        throw Exception("Gagal memuat produk: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error koneksi: $e");
    }
  }

  Future<ProductData> getProductDetail(String productId) async {
    final url = Uri.parse('$baseUrl/products/$productId');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonBody = json.decode(response.body);
          return ProductDetailResponse.fromJson(jsonBody).data;
        } catch (e) {
          // PERBAIKAN ERROR "Unexpected character <!DOCTYPE html>"
          throw Exception("Data produk ini bermasalah di Server (Error 500 Backend).");
        }
      } else if (response.statusCode == 404) {
        throw Exception("Produk tidak ditemukan.");
      } else {
        throw Exception("Gagal memuat: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }
}