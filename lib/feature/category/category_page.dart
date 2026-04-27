import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/services/category_service.dart';
import '../search/search_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<CategoryData>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
  }

  // Fungsi helper untuk menentukan ikon berdasarkan nama kategori
  IconData _getCategoryIcon(String categoryName) {
    String name = categoryName.toLowerCase();
    if (name.contains('electronic') || name.contains('elektronik') || name.contains('laptop')) return Icons.laptop_chromebook;
    if (name.contains('fashion') || name.contains('baju') || name.contains('pakaian')) return Icons.checkroom;
    if (name.contains('home') || name.contains('rumah') || name.contains('furniture')) return Icons.chair_outlined;
    if (name.contains('footwear') || name.contains('sepatu')) return Icons.directions_run;
    if (name.contains('food') || name.contains('makanan')) return Icons.fastfood_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Semua Kategori", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Dihilangkan karena ini menu utama (tab bawah)
      ),
      body: FutureBuilder<List<CategoryData>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada kategori", style: TextStyle(color: Colors.grey)));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(14)
                    ),
                    child: Icon(_getCategoryIcon(categories[index].name), color: AppColors.primaryBlue),
                  ),
                  title: Text(categories[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Lempar ke halaman pencarian dengan kata kunci kategori ini
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(initialQuery: categories[index].name)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}