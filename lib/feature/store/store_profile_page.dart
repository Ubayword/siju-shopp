import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class StoreProfilePage extends StatelessWidget {
  const StoreProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner & Header
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(height: 250, width: double.infinity, color: Colors.blueGrey), // Placeholder Banner
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
                            Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(16))),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Studio Lumina", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  Text("Curated minimalist essentials...", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.chat_bubble_outline, color: AppColors.textGrey),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat("4.9", "RATING"),
                            _buildStat("12.5k", "FOLLOWERS"),
                            _buildStat("158", "PRODUCTS"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            
            // Filter Tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab("All Items", true),
                    _buildTab("Newest", false),
                    _buildTab("Best Sellers", false),
                  ],
                ),
              ),
            ),
            
            // Produk List
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text("Product Grid Studio Lumina")),
            )
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

  Widget _buildTab(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBlue : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.bold)),
    );
  }
}