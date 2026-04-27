import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 30),
              const Text("Belum ada notifikasi baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.textDark)),
              const SizedBox(height: 12),
              const Text(
                "Promo, update pesanan, dan info menarik lainnya dari Siju Shopp akan muncul di sini.", 
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, height: 1.5, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}