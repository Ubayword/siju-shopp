import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CourierDashboardPage extends StatefulWidget {
  const CourierDashboardPage({super.key});

  @override
  State<CourierDashboardPage> createState() => _CourierDashboardPageState();
}

class _CourierDashboardPageState extends State<CourierDashboardPage> {
  int _selectedIndex = 0;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      
      // APP BAR KHUSUS KURIR
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primaryBlue),
          onPressed: () {},
        ),
        title: const Text(
          "SIJUMAN Courier", 
          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.blueGrey),
            onPressed: () {},
          )
        ],
      ),

      // KONTEN BERDASARKAN TAB YANG DIPILIH
      body: _getSelectedTab(),

      // BOTTOM NAVIGATION KHUSUS KURIR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.local_shipping, label: 'ORDERS', index: 0),
              _buildNavItem(icon: Icons.search, label: 'SEARCH', index: 1),
              _buildNavItem(icon: Icons.payments_outlined, label: 'EARNINGS', index: 2),
              _buildNavItem(icon: Icons.account_circle_outlined, label: 'PROFILE', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // LOGIKA PINDAH TAB
  Widget _getSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildOrdersDashboard(); // Halaman Utama Dashboard
      case 1:
        return const Center(child: Text("Halaman Search Segera Hadir")); // Sesuai desain Search
      case 2:
        return const Center(child: Text("Halaman Earnings Segera Hadir"));
      case 3:
        return _buildCourierProfile(); // Profil untuk kembali ke mode User
      default:
        return _buildOrdersDashboard();
    }
  }

  // ---------------------------------------------------------
  // 1. HALAMAN UTAMA (ORDERS DASHBOARD)
  // ---------------------------------------------------------
  Widget _buildOrdersDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Status Toggle Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Status", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: _isOnline ? Colors.green : Colors.grey, 
                            shape: BoxShape.circle
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline ? "Online & Active" : "Offline", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (val) => setState(() => _isOnline = val),
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.primaryBlue,
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // B. Stats Row (Total & Deliveries)
          Row(
            children: [
              Expanded(child: _buildStatCard("TODAY'S TOTAL", "\$142.50", true)),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard("DELIVERIES", "14", false)),
            ],
          ),
          const SizedBox(height: 30),

          // C. Title Nearby Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nearby Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Text("3 Available", style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // D. List Order Cards
          _buildOrderCard(
            shopName: "Fresh Bites Kitchen",
            distanceInfo: "2.4 km away • 15 mins",
            earning: "\$12.80",
            pickup: "888 Grand Ave, Suite 102",
            dropoff: "Highland Residences, Tower B",
            icon: Icons.restaurant,
            isPrimaryAction: true,
          ),
          const SizedBox(height: 15),
          _buildOrderCard(
            shopName: "Central Mart Eco",
            distanceInfo: "3.8 km away • 22 mins",
            earning: "\$8.50",
            pickup: "Westside Plaza Shopping Ctr.",
            dropoff: "Private Villa, Oak Ridge #4",
            icon: Icons.shopping_bag_outlined,
            isPrimaryAction: false,
          ),
          const SizedBox(height: 15),
          // Hot Zone Card (Dengan background Peta)
          _buildHotZoneCard(),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget Helper: Kartu Statistik Atas
  Widget _buildStatCard(String title, String value, bool isEarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isEarning ? AppColors.primaryBlue : Colors.black)),
          const SizedBox(height: 8),
          if (isEarning)
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text("12%", style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            )
          else
            const Text("Target: 20", style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // Widget Helper: Kartu Order Reguler
  Widget _buildOrderCard({
    required String shopName, required String distanceInfo, required String earning,
    required String pickup, required String dropoff, required IconData icon, required bool isPrimaryAction
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(distanceInfo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(earning, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                  const Text("EST. EARNING", style: TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          // Rute
          Row(
            children: [
              const Icon(Icons.radio_button_checked, size: 16, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(child: Text(pickup, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 7.0, top: 4, bottom: 4),
            child: SizedBox(height: 10, child: VerticalDivider(color: Colors.grey, thickness: 1)),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Expanded(child: Text(dropoff, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 25),
          // Tombol Aksi
          SizedBox(
            width: double.infinity,
            child: isPrimaryAction
                ? ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Accept Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Accept Order", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
          )
        ],
      ),
    );
  }

  // Widget Helper: Kartu Order Spesial (Hot Zone)
  Widget _buildHotZoneCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Bagian Atas: Peta & Badge Hot Zone
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  'https://via.placeholder.com/600x200/CCCCCC/FFFFFF?text=Map+Integration', 
                  height: 100, width: double.infinity, fit: BoxFit.cover
                ),
              ),
              Positioned(
                bottom: 10, left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt, color: AppColors.primaryBlue, size: 14),
                      SizedBox(width: 4),
                      Text("HOT ZONE", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                ),
              )
            ],
          ),
          // Bagian Bawah: Info & Tombol
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.local_pharmacy, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("City Pharma Plus", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text("0.9 km away • 5 mins", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$15.20", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                        Text("EST. EARNING", style: TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Accept Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 2. TAB PROFIL SEMENTARA (Tombol Kembali ke App Konsumen)
  // ---------------------------------------------------------
  Widget _buildCourierProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 20),
          const Text("Alex (Sijuman)", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context), // Kembali ke MainNavigation User
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            label: const Text("Keluar Mode Kurir", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 3. WIDGET HELPER CUSTOM BOTTOM NAV (Sesuai Desain)
  // ---------------------------------------------------------
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.transparent, // Background biru muda jika aktif
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: isActive ? AppColors.primaryBlue : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? AppColors.primaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}