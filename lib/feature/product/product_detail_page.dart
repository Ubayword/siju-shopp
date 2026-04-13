import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/product_service.dart';
import '../../core/services/cart_service.dart';
import '../checkout/checkout_page.dart'; // Import halaman checkout

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

  // State untuk menyimpan varian yang sedang dipilih user
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductDetail(widget.productId);
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark), 
            onPressed: () {
              // Navigasi ke Keranjang/Checkout saat ikon tas diklik
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
            }
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<ProductData>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("${snapshot.error}"));
          
          final product = snapshot.data!;
          final String imageUrl = product.images.isNotEmpty ? product.images.first.imageUrl : 'https://via.placeholder.com/400';

          // LOGIKA HARGA: Jika user belum memilih varian, pilih varian pertama otomatis
          final variantToDisplay = _selectedVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
          
          // Harga tampil: Harga varian terpilih. Jika tidak ada/0, pakai harga produk
          final priceToDisplay = variantToDisplay != null && variantToDisplay.price > 0 ? variantToDisplay.price : product.price;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Utama
                      Container(
                        height: 400, width: double.infinity, margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(30)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 50, color: Colors.grey)),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.type.toUpperCase(), style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            const SizedBox(height: 12),
                            
                            // Harga (Dinamis berubah saat varian diklik)
                            Text(_currencyFormat.format(priceToDisplay), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            const SizedBox(height: 25),
                            
                            // List Varian Dinamis (Bisa diklik)
                            if (product.variants.isNotEmpty) ...[
                              const Text("PILIH VARIAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10, runSpacing: 10,
                                children: product.variants.map((v) {
                                  // Cek apakah varian ini yang sedang aktif
                                  bool isActive = _selectedVariant == v || (_selectedVariant == null && v == product.variants.first);
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedVariant = v), // Update UI saat diklik
                                    child: _buildVariantBtn(v.name, isActive),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 30),
                            ],

                            // Deskripsi Box
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(24)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("DESKRIPSI PRODUK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 12),
                                  Text(_stripHtml(product.description ?? "Tidak ada deskripsi tersedia."), style: const TextStyle(color: AppColors.textGrey, height: 1.5)),
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
              // Bottom Bar dipindah ke sini agar bisa mengakses data product
              _buildBottomBar(context, product, variantToDisplay),
            ],
          );
        },
      ),
    );
  }

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

  Widget _buildBottomBar(BuildContext context, ProductData product, ProductVariant? selectedVariant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.favorite_border),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // MASUKKAN KE KERANJANG LALU TAMPILKAN NOTIFIKASI
                  CartService().addToCart(product, selectedVariant);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Berhasil ditambahkan ke keranjang!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'LIHAT', textColor: Colors.white,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage())),
                      ),
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Add to Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}