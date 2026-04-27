import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'login_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final AuthService _authService = AuthService();
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Cek otomatis setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkStatus(isManual: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool isManual = true}) async {
    if (_isChecking) return;
    if (isManual) setState(() => _isChecking = true);

    bool isVerified = await _authService.checkVerificationStatus();

    if (isVerified) {
      _timer?.cancel();
      if (!mounted) return;
      
      // Jika berhasil, kirim ke halaman LOGIN sesuai permintaan Anda
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage()), 
        (route) => false
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email berhasil diverifikasi! Silakan login."), backgroundColor: Colors.green)
      );
    } else {
      if (isManual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Belum terverifikasi. Silakan klik link di email Anda."))
        );
      }
    }

    if (isManual && mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 100, color: AppColors.primaryBlue),
              const SizedBox(height: 30),
              const Text("Cek Email Anda", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                "Link verifikasi telah dikirim ke ${widget.email}.\nSilakan klik link tersebut untuk mengaktifkan akun.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Tombol Cek Manual
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : () => _checkStatus(isManual: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isChecking 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Saya Sudah Verifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              const CircularProgressIndicator(strokeWidth: 2), // Loading kecil menunjukkan app sedang menunggu
              const SizedBox(height: 10),
              const Text("Menunggu verifikasi otomatis...", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}