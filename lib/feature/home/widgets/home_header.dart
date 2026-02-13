import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: SafeArea( // Agar tidak tertutup status bar HP
        child: Row(
          children: [
            // Search Bar
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari",
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset('assets/icons/search.png', color: Colors.grey),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Ikon-Ikon Action
            _buildHeaderIcon('assets/icons/mail.png'),
            const SizedBox(width: 12),
            _buildHeaderIcon('assets/icons/bell.png'),
            const SizedBox(width: 12),
            _buildHeaderIcon('assets/icons/cart.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(String path) {
    return InkWell(
      onTap: () {}, // Tambahkan fungsi klik di sini nanti
      child: Image.asset(
        path,
        width: 24,
        height: 24,
        color: AppColors.primaryBlue, // Menyesuaikan warna brand
      ),
    );
  }
}