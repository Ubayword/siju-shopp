import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/services/cart_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    // Ambil data keranjang dari Service
    final cartItems = CartService().items;
    final num subtotal = CartService().subtotal;
    final num tax = subtotal * 0.08; // Contoh pajak layanan 8%
    final num grandTotal = subtotal + tax;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Order Details", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
      ),
      body: cartItems.isEmpty 
      ? const Center(child: Text("Keranjang Anda Kosong", style: TextStyle(fontSize: 18, color: Colors.grey)))
      : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Service Card (Statis sesuai desain)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("SIJUMAN EXCELLENCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Icon(Icons.verified, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Hyper-local delivery within 60 minutes.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.white),
                        SizedBox(width: 10),
                        Text("Today, 2:45 PM - 3:15 PM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Your Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${cartItems.length} Items", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            
            // 2. LIST PRODUK KERANJANG DINAMIS
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final String imageUrl = item.product.images.isNotEmpty ? item.product.images.first.imageUrl : 'https://via.placeholder.com/100';
                
                return _buildOrderItem(
                  item.product.name, 
                  item.variant != null ? "Varian: ${item.variant!.name} (x${item.quantity})" : "Qty: ${item.quantity}", 
                  _currencyFormat.format(item.totalPrice),
                  imageUrl,
                  item
                );
              },
            ),

            const SizedBox(height: 30),
            const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildPaymentMethod(Icons.wallet, "Digital Wallet", true),
            _buildPaymentMethod(Icons.credit_card, "Credit / Debit Card", false),

            const SizedBox(height: 30),
            
            // 3. RINGKASAN HARGA DINAMIS
            _buildPriceSummary(subtotal, tax, grandTotal),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur API Checkout Segera Menyusul!")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text("Place Your Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, String desc, String priceStr, String imageUrl, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            width: 60, height: 60, 
            decoration: BoxDecoration(
              color: AppColors.backgroundLight, 
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            )
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), 
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 11))
              ]
            )
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(priceStr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 13)),
              const SizedBox(height: 4),
              // Tombol Hapus Barang (opsional)
              GestureDetector(
                onTap: () {
                  setState(() { CartService().removeFromCart(item); });
                },
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.primaryBlue : Colors.grey.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? AppColors.primaryBlue : AppColors.textGrey),
          const SizedBox(width: 15),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Icon(active ? Icons.radio_button_checked : Icons.radio_button_off, color: active ? AppColors.primaryBlue : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(num subtotal, num tax, num grandTotal) {
    return Column(
      children: [
        _summaryRow("Subtotal", _currencyFormat.format(subtotal)),
        _summaryRow("Delivery Fee", "Free"),
        _summaryRow("Service Tax (8%)", _currencyFormat.format(tax)),
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_currencyFormat.format(grandTotal), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ],
        )
      ],
    );
  }

  Widget _summaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: AppColors.textGrey)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}