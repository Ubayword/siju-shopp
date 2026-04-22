import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/product_service.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/wishlist_service.dart'; // Tambahkan Wishlist Service
import '../checkout/checkout_page.dart';

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
  int _quantity = 1; // State untuk jumlah barang

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
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
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
          
          final product = snapshot.data!;
          final String imageUrl = product.images.isNotEmpty ? product.images.first.imageUrl : 'https://via.placeholder.com/400';

          final variantToDisplay = _selectedVariant ?? (product.variants.isNotEmpty ? product.variants.first : null);
          final priceToDisplay = variantToDisplay != null && variantToDisplay.price > 0 ? variantToDisplay.price : product.price;
          // Pengecekan stok maksimal
          final int maxStock = variantToDisplay?.stock ?? 99;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. GAMBAR & WISHLIST BUTTON
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
                          // TOMBOL WISHLIST DINAMIS
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
                                  color: WishlistService().isWishlisted(product.id) ? Colors.red : Colors.grey
                                ),
                              ),
                            ),
                          ),
                        ],
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
                            
                            // Harga
                            Text(_currencyFormat.format(priceToDisplay), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            const SizedBox(height: 25),
                            
                            // Varian
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
                                      _quantity = 1; // Reset qty jika ganti varian
                                    }),
                                    child: _buildVariantBtn(v.name, isActive),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 30),
                            ],

                            // Deskripsi
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
              // 2. ACTION BAR BAWAH (QTY, ADD TO CART, BUY NOW)
              _buildBottomActionPanel(context, product, variantToDisplay, maxStock),
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

  // Panel Bawah Lengkap (Seperti PurchaseActionCard.tsx di web)
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
            // Baris 1: Atur Jumlah (Qty)
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
            
            // Baris 2: Tombol Cart & Buy Now
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      CartService().addToCart(product, selectedVariant, qty: _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ditambahkan ke keranjang!'), backgroundColor: Colors.green));
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
                      // Set sebagai Buy Now Item lalu lompat ke Checkout
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