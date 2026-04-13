import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/product_service.dart';

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

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductDetail(widget.productId);
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
          IconButton(icon: const Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textDark), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: FutureBuilder<ProductData>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          final product = snapshot.data!;
          final variant = product.variants.isNotEmpty ? product.variants.first : null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Gambar Utama & Badge
                Stack(
                  children: [
                    Container(
                      height: 400,
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: NetworkImage(variant?.imageUrl ?? 'https://via.placeholder.com/400'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
                        child: const Text("NEW ARRIVAL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("LIMITED EDITION", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(_currencyFormat.format(variant?.price ?? 0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          const SizedBox(width: 10),
                          Text(_currencyFormat.format((variant?.price ?? 0) * 1.2), style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                      
                      const SizedBox(height: 25),
                      const Text("SELECT PALETTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildColorDot(Colors.grey.shade300, true),
                          _buildColorDot(Colors.black, false),
                          _buildColorDot(Colors.blueGrey, false),
                          _buildColorDot(Colors.brown, false),
                        ],
                      ),

                      const SizedBox(height: 25),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("SELECT SIZE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark)),
                          Text("Size Guide", style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, decoration: TextDecoration.underline)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSizeBtn("EU 40", false),
                          _buildSizeBtn("EU 41", true),
                          _buildSizeBtn("EU 42", false),
                          _buildSizeBtn("EU 43", false),
                        ],
                      ),

                      const SizedBox(height: 30),
                      // Deskripsi Box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("THE NARRATIVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 12),
                            Text(product.description ?? "Crafted for the modern wanderer...", style: const TextStyle(color: AppColors.textGrey, height: 1.5)),
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                Icon(Icons.eco, size: 16, color: AppColors.primaryBlue),
                                SizedBox(width: 8),
                                Text("SUSTAINABLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                SizedBox(width: 20),
                                Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryBlue),
                                SizedBox(width: 8),
                                Text("ARTISAN MADE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorDot(Color color, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: active ? AppColors.primaryBlue : Colors.transparent, width: 2)),
      child: CircleAvatar(backgroundColor: color, radius: 14),
    );
  }

  Widget _buildSizeBtn(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? AppColors.primaryBlue : Colors.grey.shade200),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
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
                onPressed: () {},
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