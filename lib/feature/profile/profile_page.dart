import 'package:flutter/material.dart';
import 'package:siju_shopp/feature/wishlist/wishlist_page.dart';
import '../../core/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../courier/courier_dashboard_page.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  
  bool _isLoggedIn = false;
  Map<String, String> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek apakah ada token yang tersimpan di HP
  Future<void> _checkLoginStatus() async {
    bool loggedIn = await _authService.isLoggedIn();
    Map<String, String> userData = {};
    if (loggedIn) {
      userData = await _authService.getUserData();
    }
    setState(() {
      _isLoggedIn = loggedIn;
      _userData = userData;
      _isLoading = false;
    });
  }

  // Fungsi Log Out
  void _handleLogout() async {
    // Tampilkan loading dialog
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (c) => const Center(child: CircularProgressIndicator())
    );
    
    await _authService.logout();
    
    if (!mounted) return;
    Navigator.pop(context); // Tutup loading dialog
    _checkLoginStatus(); // Refresh halaman agar kembali jadi mode Guest
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil Log Out"), backgroundColor: Colors.green)
    );
  }

  // Fungsi untuk mengecek akses saat menu diklik
  void _requireAuthAction(String featureName) {
    if (_isLoggedIn) {
      // Jika sudah login, izinkan masuk (sementara muncul pesan)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Halaman $featureName sedang dibangun")));
    } else {
      // Jika belum login, munculkan peringatan & tombol Login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Harap Login untuk mengakses $featureName"),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "LOGIN", 
            textColor: Colors.white,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          ),
        ),
      );
    }
  }

  // Fungsi mensensor email (Seperti maskEmail di web ISC)
  String _maskEmail(String email) {
    if (!email.contains("@")) return email;
    final parts = email.split("@");
    final name = parts[0];
    final domain = parts[1];
    
    if (name.length <= 3) return email;
    
    final first = name.substring(0, 2);
    final last = name.substring(name.length - 1);
    final masked = "*" * (name.length - 3);
    
    return "$first$masked$last@$domain";
  }

  // Pop-up Modal untuk Edit Profil
  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          // Padding bawah agar form tidak tertutup keyboard
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Profil", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Input Username
              TextFormField(
                initialValue: _userData['name'],
                decoration: const InputDecoration(labelText: "Username / Nama", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // Input Email (Readonly dengan Masking)
              TextFormField(
                initialValue: _maskEmail(_userData['email'] ?? ''),
                readOnly: true, // Email tidak bisa diubah dari sini
                decoration: const InputDecoration(
                  labelText: "Email Terdaftar", 
                  border: OutlineInputBorder(), 
                  suffixIcon: Icon(Icons.lock, color: Colors.grey)
                ),
              ),
              const SizedBox(height: 15),

              // Pilihan Gender
              const Text("Jenis Kelamin", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("L", style: TextStyle(fontSize: 14)), 
                      value: "male", 
                      groupValue: "male", 
                      onChanged: (v){}
                    )
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("P", style: TextStyle(fontSize: 14)), 
                      value: "female", 
                      groupValue: "male", 
                      onChanged: (v){}
                    )
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil Berhasil Diperbarui!"), backgroundColor: Colors.green));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading saat pertama kali mengecek status login
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text("My Account", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Settings Umum (Bisa diakses publik)")));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==========================================
            // 1. KARTU PROFIL UTAMA
            // ==========================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Warna biru jika login, biru gelap/abu-abu jika guest
                color: _isLoggedIn ? AppColors.primaryBlue : Colors.blueGrey.shade800,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_isLoggedIn ? AppColors.primaryBlue : Colors.blueGrey).withOpacity(0.3), 
                    blurRadius: 15, offset: const Offset(0, 8)
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(_isLoggedIn ? Icons.person : Icons.person_off, size: 40, color: Colors.grey),
                  ),
                  const SizedBox(width: 15),
                  
                  // Info Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoggedIn ? _userData['name']! : "Halo, Tamu!", 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoggedIn ? _userData['email']! : "Masuk untuk nikmati kemudahan belanja", 
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)
                        ),
                        
                        // Badge Role jika sudah login
                        if (_isLoggedIn) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2), 
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Text(
                              _userData['role']!.toUpperCase(), 
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                  
                  // Tombol Aksi (Edit vs Login)
                  if (_isLoggedIn)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _showEditProfileModal,
                    )
                  else
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, 
                        foregroundColor: Colors.blueGrey.shade800, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ==========================================
            // 2. STATISTIK CEPAT (Hanya muncul jika login)
            // ==========================================
            if (_isLoggedIn) ...[
              Row(
                children: [
                  Expanded(child: _buildQuickStatCard(Icons.monetization_on, "Coins", "1,250", Colors.orange)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildQuickStatCard(Icons.local_activity, "Vouchers", "4 Active", Colors.teal)),
                ],
              ),
              const SizedBox(height: 30),
            ],

            // ==========================================
            // 3. MENU DASHBOARD
            // ==========================================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  // Menu yang butuh login (isProtected = true)
                  _buildMenuItem(Icons.shopping_bag_outlined, "My Orders", "Lacak riwayat pesanan", true),
                  _buildDivider(),
                  _buildMenuItem(Icons.favorite_border, "Wishlist", "Barang yang Anda simpan", true, onTap: () {
  if (_isLoggedIn) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
  } else {
     _requireAuthAction("Wishlist");
  }
}),
                  _buildDivider(),
                  _buildMenuItem(Icons.location_on_outlined, "Saved Addresses", "Atur alamat pengiriman", true),
                  _buildDivider(),
                  // Fitur publik (isProtected = false)
                  _buildMenuItem(Icons.help_outline, "Help Center", "Bantuan & Pertanyaan FAQ", false),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ==========================================
            // 4. TOMBOL SIJUMAN PORTAL 
            // (Khusus Role Kurir atau Admin)
            // ==========================================
            if (_isLoggedIn && (_userData['role'] == 'sijuman' || _userData['role'] == 'admin'))
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delivery_dining, color: Colors.blueGrey),
                  ),
                  title: const Text("Sijuman Portal", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Beralih ke mode pengantaran", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CourierDashboardPage())),
                ),
              ),
            
            // ==========================================
            // 5. TOMBOL LOGOUT (Hanya muncul jika login)
            // ==========================================
            if (_isLoggedIn)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, 
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildQuickStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, bool isProtected, {VoidCallback? onTap}) {
    // Jika menu diproteksi dan user belum login, warnanya abu-abu
    bool isDisabled = isProtected && !_isLoggedIn;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: isDisabled ? Colors.grey : AppColors.primaryBlue),
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 14, 
          color: isDisabled ? Colors.grey : AppColors.textDark
        )
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap ?? () {
        if (isProtected) {
          _requireAuthAction(title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Membuka $title...")));
        }
      },
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 70, endIndent: 20);
  }
}