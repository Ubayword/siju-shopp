import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/product_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId; // ID produk wajib dikirim dari halaman sebelumnya

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<ProductData> _productFuture;
  final ProductService _productService = ProductService();
  
  // Format Rupiah
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductDetail(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- 1. Header (AppBar) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'assets/icons/arrow_back.png', // Pastikan aset ini ada
              width: 24,
              height: 24,
              errorBuilder: (ctx, err, stack) => const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        actions: [
          _headerIcon('assets/icons/search.png', () {}),
          _headerIcon('assets/icons/share.png', () {}),
          _headerIcon('assets/icons/cart.png', () {}),
          const SizedBox(width: 10),
        ],
      ),

      // --- 2. Bottom Bar (Tombol Beli) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Tombol Chat
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/icons/chat.png',
                  color: Colors.grey[700],
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.chat, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 10),
              
              // Tombol Beli Langsung
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Beli Langsung",
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // Tombol + Keranjang
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "+ Keranjang",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // --- 3. Konten Utama (FutureBuilder) ---
      body: FutureBuilder<ProductData>(
        future: _productFuture,
        builder: (context, snapshot) {
          // A. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // B. Error State
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                ],
              ),
            );
          } 
          // C. Success State
          else if (snapshot.hasData) {
            final product = snapshot.data!;
            
            // Logika Varian: Ambil varian pertama sebagai default
            final defaultVariant = product.variants.isNotEmpty ? product.variants.first : null;
            final String imageUrl = defaultVariant?.imageUrl ?? 'https://via.placeholder.com/400';
            final num price = defaultVariant?.price ?? 0;
            final int stock = defaultVariant?.stock ?? 0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Container(
                    height: 375,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                    ),
                  ),

                  // Detail Info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harga
                        Text(
                          _currencyFormat.format(price),
                          style: const TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primaryBlue
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Nama Produk
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
                        ),
                        
                        const SizedBox(height: 12),

                        // Rating & Terjual (Data statis dulu karena tidak ada di endpoint detail product)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/icons/star.png', width: 14, height: 14, errorBuilder: (c,e,s) => const Icon(Icons.star, size: 14, color: Colors.orange)),
                                  const SizedBox(width: 4),
                                  const Text("5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Stok (Ambil dari varian)
                            Text("Stok: $stock", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),

                        const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),

                        // Detail Produk Header
                        const Text(
                          "Detail Produk",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        
                        // Spesifikasi
                        _buildSpecificationRow("Kategori ID", product.categoryId.toString()),
                        _buildSpecificationRow("Toko ID", product.shopId.toString()),
                        _buildSpecificationRow("Tipe", product.type),
                        
                        const SizedBox(height: 20),
                        
                        // Deskripsi Body
                        const Text(
                          "Deskripsi",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description ?? "Tidak ada deskripsi.",
                          style: TextStyle(color: Colors.grey[700], height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Data tidak ditemukan"));
        },
      ),
    );
  }

  Widget _headerIcon(String assetPath, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          assetPath,
          width: 24,
          height: 24,
          errorBuilder: (ctx, err, stack) => const Icon(Icons.circle, size: 24, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}