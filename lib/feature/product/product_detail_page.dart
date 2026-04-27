import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/product_service.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/wishlist_service.dart';
import '../checkout/checkout_page.dart';
import '../store/store_profile_page.dart'; // Import halaman toko

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductService _productService = ProductService();
  late Future<ProductData> _productFuture;
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  ProductVariant? _selectedVariant;
  int _quantity = 1; // Menyimpan jumlah barang yang mau dibeli

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductDetail(widget.productId);
  }

  // Membersihkan tag HTML dari API (seperti <p>, <br>, dll)
  String _stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark), 
          onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()))
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<ProductData>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: Text("Produk tidak ditemukan"));
          
          final product = snapshot.data!;
          final String imageUrl = product.images.isNotEmpty ? product.images.first.imageUrl : 'https://via.placeholder.com/400';

          // Menentukan varian aktif & harga
          final variantToDisplay = _selectedVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
          final priceToDisplay = variantToDisplay != null && variantToDisplay.price > 0 ? variantToDisplay.price : product.price;
          final int maxStock = variantToDisplay?.stock ?? 99; // Batas stok

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // 1. GAMBAR & TOMBOL WISHLIST
                      // ==========================================
                      Stack(
                        children: [
                          Container(
                            height: 400, width: double.infinity, margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(30)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 50, color: Colors.grey)),
                            ),
                          ),
                          Positioned(
                            top: 40, right: 40,
                            child: GestureDetector(
                              onTap: () async {
                                await WishlistService().toggleWishlist(product.id);
                                setState(() {}); // Refresh UI agar hati berubah warna
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                child: Icon(
                                  WishlistService().isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border, 
                                  color: WishlistService().isWishlisted(product.id) ? Colors.red : Colors.grey,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ==========================================
                      // 2. INFO PRODUK UTAMA
                      // ==========================================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.type.toUpperCase(), style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 12),
                            
                            Text(_currencyFormat.format(priceToDisplay), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            const SizedBox(height: 25),
                            
                            // ==========================================
                            // 3. PILIHAN VARIAN
                            // ==========================================
                            if (product.variants.isNotEmpty) ...[
                              const Text("PILIH VARIAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10, runSpacing: 10,
                                children: product.variants.map((v) {
                                  bool isActive = _selectedVariant == v || (_selectedVariant == null && v == product.variants.first);
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedVariant = v;
                                      _quantity = 1; // Reset qty jika user ganti varian
                                    }),
                                    child: _buildVariantBtn(v.name, isActive),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 30),
                            ],

                            // ==========================================
                            // 4. SISTEM TAB (DESKRIPSI & INFO TOKO)
                            // ==========================================
                            DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  const TabBar(
                                    labelColor: AppColors.primaryBlue,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: AppColors.primaryBlue,
                                    indicatorWeight: 3,
                                    tabs: [
                                      Tab(text: "Deskripsi"),
                                      Tab(text: "Info Toko"),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 300, // Tinggi tab view agar bisa di-scroll
                                    child: TabBarView(
                                      children: [
                                        // TAB 1: DESKRIPSI
                                        SingleChildScrollView(
                                          child: Text(
                                            _stripHtml(product.description ?? "Tidak ada deskripsi tersedia."),
                                            style: const TextStyle(color: AppColors.textGrey, height: 1.5, fontSize: 14),
                                          ),
                                        ),
                                        
                                        // TAB 2: INFO TOKO
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.backgroundLight,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: product.shop.logoUrl != null ? NetworkImage(product.shop.logoUrl!) : null,
                                                    child: product.shop.logoUrl == null ? const Icon(Icons.store, color: AppColors.primaryBlue) : null,
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(product.shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                        const SizedBox(height: 4),
                                                        const Text("Penjual Terverifikasi", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      // Lompat ke Halaman Profil Toko
                                                      Navigator.push(
                                                        context, 
                                                        MaterialPageRoute(builder: (context) => StoreProfilePage(shop: product.shop))
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.primaryBlue,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text("Kunjungi", style: TextStyle(color: Colors.white)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                _buildShopBadge(Icons.star, "${product.shop.rating}", "Rating Toko"),
                                                _buildShopBadge(Icons.inventory_2, "10+", "Produk"),
                                                _buildShopBadge(Icons.verified_user, "100%", "Ori"),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ==========================================
              // 5. PANEL BAWAH (QTY, ADD TO CART, BUY NOW)
              // ==========================================
              _buildBottomActionPanel(context, product, variantToDisplay, maxStock),
            ],
          );
        },
      ),
    );
  }

  // Widget Helper: Tombol Varian
  Widget _buildVariantBtn(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.primaryBlue : Colors.grey.shade300),
      ),
      child: Text(text, style: TextStyle(color: isActive ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // Widget Helper: Badge Info Toko
  Widget _buildShopBadge(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  // Widget Helper: Action Bar Bawah
  Widget _buildBottomActionPanel(BuildContext context, ProductData product, ProductVariant? selectedVariant, int maxStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Baris Atas: Atur Kuantitas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Atur Jumlah", style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: _quantity < maxStock ? () => setState(() => _quantity++) : null,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            
            // Baris Bawah: Tombol Keranjang & Beli
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      CartService().addToCart(product, selectedVariant, qty: _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil ditambahkan ke keranjang!'), backgroundColor: Colors.green));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("+ Keranjang", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      CartService().setBuyNow(product, selectedVariant);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Beli Langsung", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}