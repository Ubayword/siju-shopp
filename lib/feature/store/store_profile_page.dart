import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/services/shop_service.dart';
import '../product/product_detail_page.dart';

class StoreProfilePage extends StatefulWidget {
  final String shopSlug; // Menerima slug dari halaman sebelumnya

  const StoreProfilePage({super.key, required this.shopSlug});

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  final ShopService _shopService = ShopService();
  late Future<ShopData> _shopFuture;
  late Future<List<ProductData>> _productsFuture;
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Memanggil 2 API sekaligus: Profil Toko & Produk Toko
    _shopFuture = _shopService.getShopDetail(widget.shopSlug);
    _productsFuture = _shopService.getShopProducts(widget.shopSlug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER TOKO (FutureBuilder Profil)
            FutureBuilder<ShopData>(
              future: _shopFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox(height: 250, child: Center(child: Text("Gagal memuat toko")));
                }

                final shop = snapshot.data!;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(height: 250, width: double.infinity, color: Colors.blueGrey),
                    SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 70, 
                                  height: 70, 
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight, 
                                    borderRadius: BorderRadius.circular(16),
                                    image: shop.logoUrl != null ? DecorationImage(image: NetworkImage(shop.logoUrl!), fit: BoxFit.cover) : null,
                                  ),
                                  child: shop.logoUrl == null ? const Icon(Icons.store, size: 30) : null,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(shop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      const Text("Official Merchant", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat(shop.rating.toString(), "RATING"),
                                _buildStat("${shop.ratingCount}", "ULASAN"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
            
            const SizedBox(height: 90),
            
            // 2. GRID PRODUK TOKO (FutureBuilder Produk)
            FutureBuilder<List<ProductData>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Error: ${snapshot.error}")));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Toko ini belum memiliki produk.")));
                }

                final products = snapshot.data!;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
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
                      final String imageUrl = product.images.isNotEmpty ? product.images.first.imageUrl : 'https://via.placeholder.com/200';

                      return _buildProductCard(context, product, imageUrl);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
      ],
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
              ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}