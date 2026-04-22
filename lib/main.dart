import 'package:flutter/material.dart';
import 'package:siju_shopp/feature/home/home_page.dart';
import 'package:siju_shopp/feature/profile/profile_page.dart';
import 'core/app_colors.dart';

void main() {
  runApp(const SijuShoppApp());
}

class SijuShoppApp extends StatelessWidget {
  const SijuShoppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIJU SHOPP',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: 'Roboto', 
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Daftar halaman statis untuk sementara
  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text("Halaman Categories")),
    const Center(child: Text("Halaman Alerts")),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _pages[_selectedIndex],
      
      // CUSTOM BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(icon: Icons.home_filled, label: 'HOME', index: 0),
              _buildNavItem(icon: Icons.grid_view_rounded, label: 'CATEGORIES', index: 1),
              _buildNavItem(icon: Icons.notifications_rounded, label: 'ALERTS', index: 2),
              _buildNavItem(icon: Icons.person_rounded, label: 'PROFILE', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET TOMBOL NAVIGATION
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Jika aktif, background jadi biru. Jika tidak, transparan.
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16), // Sudut melengkung
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              // Jika aktif icon putih, jika tidak icon abu-abu
              color: isActive ? Colors.white : AppColors.textGrey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                // Jika aktif teks putih, jika tidak teks abu-abu
                color: isActive ? Colors.white : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}