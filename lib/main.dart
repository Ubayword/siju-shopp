import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'core/app_colors.dart';
import 'core/models/product_model.dart';
import 'core/services/product_service.dart';
import 'feature/home/widgets/category_grid.dart';
import 'feature/home/widgets/home_header.dart';
import 'feature/home/widgets/product_card.dart';
import 'feature/product/product_detail_page.dart';

void main() {
  runApp(const SijuShoppApp());
}

class SijuShoppApp extends StatelessWidget {
  const SijuShoppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIJU SHOPP',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  // Service untuk mengambil data
  final ProductService _productService = ProductService();
  
  // Future untuk menampung data list produk
  late Future<List<ProductData>> _productsFuture;

  // Format Rupiah
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Panggil API saat aplikasi pertama dibuka
    _productsFuture = _productService.getProducts();
  }

  // Fungsi untuk refresh data (tarik layar ke bawah)
  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _productService.getProducts();
    });
  }

  Widget customIcon(String path, bool isSelected) {
    return Image.asset(
      path,
      width: 24,
      height: 24,
      color: isSelected ? AppColors.primaryBlue : Colors.grey,
      errorBuilder: (c, e, s) => Icon(Icons.circle, color: isSelected ? AppColors.primaryBlue : Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Halaman Home didefinisikan di sini agar bisa akses _productsFuture
    final Widget homePage = RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Column(
        children: [
          const HomeHeader(),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Grid Kategori
                    const SizedBox(height: 10),
                    const CategoryGrid(),
                    const SizedBox(height: 10),

                    // 2. Grid Produk
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FutureBuilder<List<ProductData>>(
                        future: _productsFuture,
                        builder: (context, snapshot) {
                          // A. Loading
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          // B. Error
                          else if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text("Gagal memuat: ${snapshot.error}"),
                              ),
                            );
                          }
                          // C. Data Kosong
                          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("Belum ada produk tersedia"),
                            ));
                          }

                          // D. Ada Data
                          final products = snapshot.data!;
                          
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              
                              // Ambil varian pertama untuk tampilan di kartu (Cover)
                              final firstVariant = product.variants.isNotEmpty ? product.variants.first : null;
                              final String imageUrl = firstVariant?.imageUrl ?? 'https://via.placeholder.com/150';
                              final num price = firstVariant?.price ?? 0;

                              return GestureDetector(
                                onTap: () {
                                  // Kita kirim ID Asli (product.id) ke halaman detail
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(productId: product.id),
                                    ),
                                  );
                                },
                                child: ProductCard(
                                  imageUrl: imageUrl,
                                  title: product.name,
                                  price: _currencyFormat.format(price),
                                  // Data dummy untuk yang belum ada di API list
                                  originalPrice: null, 
                                  discountPercent: null,
                                  rating: '5.0',
                                  soldCount: '${firstVariant?.stock ?? 0}', 
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final List<Widget> pages = [
      homePage,
      const Center(child: Text("Feed")),
      const Center(child: Text("Promo")),
      const Center(child: Text("Transaksi")),
      const Center(child: Text("Akun")),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: customIcon('assets/icons/home.png', _selectedIndex == 0), label: 'Home'),
          BottomNavigationBarItem(icon: customIcon('assets/icons/feed.png', _selectedIndex == 1), label: 'Feed'),
          BottomNavigationBarItem(icon: customIcon('assets/icons/promo.png', _selectedIndex == 2), label: 'Promo'),
          BottomNavigationBarItem(icon: customIcon('assets/icons/transaction.png', _selectedIndex == 3), label: 'Transaksi'),
          BottomNavigationBarItem(icon: customIcon('assets/icons/profile.png', _selectedIndex == 4), label: 'Akun'),
        ],
      ),
    );
  }
}