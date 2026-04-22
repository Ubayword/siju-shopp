import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  List<String> _wishlist = [];

  // Panggil ini saat aplikasi baru dibuka (misal di main.dart)
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    _wishlist = prefs.getStringList('wishlist_items') ?? [];
  }

  Future<void> toggleWishlist(String productId) async {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist_items', _wishlist);
  }

  bool isWishlisted(String productId) {
    return _wishlist.contains(productId);
  }

  List<String> get items => _wishlist;
}