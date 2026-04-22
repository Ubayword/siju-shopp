import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryData {
  final String id;
  final String name;
  final String slug;

  CategoryData({required this.id, required this.name, required this.slug});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Kategori',
      slug: json['slug'] ?? '',
    );
  }
}

class CategoryService {
  final String baseUrl = "https://api.isc-webdev.my.id/api/v1";

  Future<List<CategoryData>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        var list = jsonBody['data'] as List? ?? [];
        return list.map((i) => CategoryData.fromJson(i)).toList();
      } else {
        throw Exception("Gagal memuat kategori");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}