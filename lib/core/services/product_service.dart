import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = "https://api.isc-webdev.my.id/api";

  // 1. Ambil List Produk (Untuk Home)
  Future<List<ProductData>> getProducts() async {
    final url = Uri.parse('$baseUrl/products'); // Endpoint List

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        // Parsing respons list
        ProductListResponse listResponse = ProductListResponse.fromJson(jsonBody);
        return listResponse.data;
      } else {
        throw Exception("Gagal memuat produk: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error koneksi: $e");
    }
  }

  // 2. Ambil Detail
  Future<ProductData> getProductDetail(String productId) async {
    final url = Uri.parse('$baseUrl/products/$productId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        ProductDetailResponse responseModel = ProductDetailResponse.fromJson(jsonBody);
        return responseModel.data;
      } else if (response.statusCode == 404) {
        throw Exception("Produk tidak ditemukan");
      } else {
        throw Exception("Gagal memuat: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error koneksi: $e");
    }
  }
}