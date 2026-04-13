import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Service Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(24)),
              child: Column(
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
            const Text("Your Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // List Item (contoh)
            _buildOrderItem("CloudRunner Elite v2", "Size: 42 • Obsidian Red", "189.00"),
            _buildOrderItem("Nexus Smart Dial", "Silver Edition", "349.00"),

            const SizedBox(height: 30),
            const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildPaymentMethod(Icons.wallet, "Digital Wallet", true),
            _buildPaymentMethod(Icons.credit_card, "Credit / Debit Card", false),

            const SizedBox(height: 30),
            _buildPriceSummary(),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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

  Widget _buildOrderItem(String name, String desc, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 11))])),
          Text("\$$price", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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

  Widget _buildPriceSummary() {
    return Column(
      children: [
        _summaryRow("Subtotal", "\$538.00"),
        _summaryRow("Delivery Fee", "Free"),
        _summaryRow("Service Tax (8%)", "\$43.04"),
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("\$581.04", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
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