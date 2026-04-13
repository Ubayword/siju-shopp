import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ShopService {
  final String baseUrl = "https://api.isc-webdev.my.id/api/v1";

  // Ambil detail toko
  Future<ShopData> getShopDetail(String slug) async {
    final url = Uri.parse('$baseUrl/shops/$slug');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        return ShopData.fromJson(jsonBody['data']);
      } else {
        throw Exception("Gagal memuat detail toko.");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Ambil list produk milik toko tersebut
  Future<List<ProductData>> getShopProducts(String slug) async {
    final url = Uri.parse('$baseUrl/shops/$slug/products');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        var list = jsonBody['data'] as List? ?? [];
        return list.map((i) => ProductData.fromJson(i)).toList();
      } else {
        throw Exception("Gagal memuat produk toko.");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}