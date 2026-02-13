import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Data kategori (bisa dipindah ke file konstanta nanti)
    final List<Map<String, String>> categories = [
      {'name': 'Top-Up & Tagihan', 'icon': 'assets/icons/topup.png'},
      {'name': 'Mall', 'icon': 'assets/icons/mall.png'},
      {'name': 'Fashion', 'icon': 'assets/icons/fashion.png'},
      {'name': 'Beauty', 'icon': 'assets/icons/beauty.png'},
      {'name': 'Unpam Farma', 'icon': 'assets/icons/unpam_farma.png'},
      {'name': 'Promo Hari Ini', 'icon': 'assets/icons/promo.png'},
      {'name': 'Kita Punya', 'icon': 'assets/icons/lokal.png'},
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: GridView.builder(
        shrinkWrap: true, // Penting agar bisa masuk ke dalam ScrollView
        physics: const NeverScrollableScrollPhysics(), // Scroll ditangani oleh parent
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Menampilkan 4 kolom
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8, // Mengatur proporsi kotak (tinggi > lebar)
        ),
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wadah Ikon PNG
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  categories[index]['icon']!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              // Teks Label
              Text(
                categories[index]['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}