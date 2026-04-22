import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siju_shopp/core/services/wishlist_service.dart';
import 'package:siju_shopp/feature/cart/cart_page.dart';
import 'package:siju_shopp/feature/search/search_page.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/product_service.dart';
import '../../core/services/category_service.dart'; // Import Service Kategori
import '../product/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  
  late Future<List<ProductData>> _productsFuture;
  late Future<List<CategoryData>> _categoriesFuture;
  
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _productsFuture = _productService.getProducts();
    _categoriesFuture = _categoryService.getCategories();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
    });
  }

  // Fungsi untuk memetakan nama kategori ke ikon bawaan Flutter
  IconData _getCategoryIcon(String categoryName) {
    String name = categoryName.toLowerCase();
    if (name.contains('electronic') || name.contains('elektronik') || name.contains('laptop')) return Icons.laptop_chromebook;
    if (name.contains('fashion') || name.contains('baju') || name.contains('pakaian')) return Icons.checkroom;
    if (name.contains('home') || name.contains('rumah') || name.contains('furniture')) return Icons.chair_outlined;
    if (name.contains('footwear') || name.contains('sepatu')) return Icons.directions_run;
    if (name.contains('food') || name.contains('makanan')) return Icons.fastfood_outlined;
    return Icons.category_outlined; // Ikon default
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      // Mengarahkan ke SearchPage dengan membawa query
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(initialQuery: query),
        ),
      );
      // Opsional: Kosongkan field di Home setelah pindah
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // 1. HEADER (Search Dinamis)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: _handleSearch,
                                readOnly: true, // Ubah jadi readOnly agar user diarahkan ke SearchPage
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                                },
                                decoration: const InputDecoration(
                                hintText: "Search curated collections...",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue, size: 28),
                      onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                      },
                  ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // 2. BANNER (Desain Mobile Tetap Dipertahankan)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Text("NEW RELEASE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      const Text("Seasonal\nDrop.", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                      const SizedBox(height: 8),
                      const Text("Limited edition essentials\ndesigned for the digital curator.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Explore Now", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 3. CATEGORIES TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View all", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                // 4. CATEGORIES GRID (DINAMIS DARI API)
                FutureBuilder<List<CategoryData>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("Belum ada kategori", style: TextStyle(color: Colors.grey));
                    }

                    final categories = snapshot.data!;
                    // Ambil maksimal 4 kategori agar desain UI tetap rapi seperti mock-up awal
                    final displayCategories = categories.take(4).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 2.2, 
                      ),
                      itemBuilder: (context, index) {
                        final cat = displayCategories[index];
                        return _buildCategoryItem(_getCategoryIcon(cat.name), cat.name);
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 5. TRENDING NOW TITLE
                const Text("Trending Now", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 15),

                // 6. PRODUCT GRID DARI API
                FutureBuilder<List<ProductData>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Error: ${snapshot.error}")));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Belum ada produk")));
                    }

                    final products = snapshot.data!;
                    
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.60,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final String imageUrl = product.images.isNotEmpty 
                            ? product.images.first.imageUrl 
                            : 'https://via.placeholder.com/200';

                        return _buildProductCard(context, product, imageUrl);
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title, 
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductData product, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
               Positioned(
  top: 10, right: 10,
  child: GestureDetector(
    onTap: () async {
      await WishlistService().toggleWishlist(product.id);
      setState(() {}); // Memperbarui state agar warna hati langsung berubah
    },
    child: CircleAvatar(
      backgroundColor: Colors.white.withOpacity(0.9), radius: 14,
      child: Icon(
        WishlistService().isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border, 
        color: WishlistService().isWishlisted(product.id) ? Colors.red : Colors.grey, 
        size: 16
      ),
    ),
  ),
),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(product.shortDescription ?? product.type, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 12),
                  Text(_currencyFormat.format(product.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${product.soldCount} terjual", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 10, color: AppColors.primaryBlue),
                            SizedBox(width: 2),
                            Text("4.9", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}