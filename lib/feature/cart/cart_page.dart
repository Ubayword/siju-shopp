import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/services/cart_service.dart';
import '../checkout/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  void _refreshCart() {
    setState(() {}); // Memperbarui UI setiap ada perubahan dari CartService
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartService().items;
    
    // Cek apakah semua item terpilih (untuk checkbox "Pilih Semua")
    bool isAllSelected = cartItems.isNotEmpty && cartItems.every((item) => item.selected);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: const Text("Keranjang Saya", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                CartService().clearCart();
                _refreshCart();
              },
              child: const Text("Hapus Semua", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 100), // Spasi bawah untuk BottomBar
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final String imageUrl = item.product.images.isNotEmpty ? item.product.images.first.imageUrl : 'https://via.placeholder.com/100';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      Checkbox(
                        value: item.selected,
                        activeColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          CartService().toggleSelect(item);
                          _refreshCart();
                        },
                      ),
                      // Gambar
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Detail & Kontrol
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            if (item.variant != null)
                              Text("Varian: ${item.variant!.name}", style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                            const SizedBox(height: 8),
                            Text(_currencyFormat.format(item.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          ],
                        ),
                      ),
                      // Kontrol Qty
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            onPressed: () {
                              CartService().removeFromCart(item);
                              _refreshCart();
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    CartService().updateQty(item, item.quantity - 1);
                                    _refreshCart();
                                  },
                                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Icon(Icons.remove, size: 16)),
                                ),
                                Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                InkWell(
                                  onTap: () {
                                    CartService().updateQty(item, item.quantity + 1);
                                    _refreshCart();
                                  },
                                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Icon(Icons.add, size: 16)),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            
      // BOTTOM BAR CHECKOUT
      bottomSheet: cartItems.isEmpty ? null : Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: SafeArea(
          child: Row(
            children: [
              Checkbox(
                value: isAllSelected,
                activeColor: AppColors.primaryBlue,
                onChanged: (val) {
                  for (var item in cartItems) {
                    item.selected = val ?? false;
                  }
                  _refreshCart();
                },
              ),
              const Text("Semua", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Total Harga", style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                  Text(
                    _currencyFormat.format(CartService().totalSelectedPrice), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)
                  ),
                ],
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: CartService().totalSelectedItems > 0 
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()))
                  : null, // Mati jika tidak ada barang yang diceklis
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text("Checkout (${CartService().totalSelectedItems})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Keranjangmu masih kosong", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text("Yuk, cari barang-barang impianmu sekarang!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}