import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductData product;
  final ProductVariant? variant;
  int quantity;
  bool selected; // Fitur checkbox untuk checkout

  CartItem({required this.product, this.variant, this.quantity = 1, this.selected = true});

  num get price => variant != null && variant!.price > 0 ? variant!.price : product.price;
  num get subtotal => price * quantity;
}

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> items = [];
  CartItem? buyNowItem; // Fitur Beli Langsung (Bypass keranjang utama)

  // LOGIKA TAMBAH KE KERANJANG (Sesuai web)
  void addToCart(ProductData product, ProductVariant? variant, {int qty = 1}) {
    var existingItemIndex = items.indexWhere((i) => i.product.id == product.id && i.variant?.id == variant?.id);
    
    // Pengecekan stok maksimal seperti di web
    int maxStock = variant?.stock ?? 99; // Asumsi 99 jika stok utama tidak di-map
    
    if (existingItemIndex >= 0) {
      int newQty = items[existingItemIndex].quantity + qty;
      items[existingItemIndex].quantity = newQty > maxStock ? maxStock : newQty;
    } else {
      int safeQty = qty > maxStock ? maxStock : qty;
      items.add(CartItem(product: product, variant: variant, quantity: safeQty));
    }
    _saveCartLocally();
  }

  // Update Kuantitas
  void updateQty(CartItem item, int newQty) {
    int maxStock = item.variant?.stock ?? 99;
    int safeQty = newQty > maxStock ? maxStock : (newQty < 1 ? 1 : newQty);
    item.quantity = safeQty;
    _saveCartLocally();
  }

  // Toggle Checkbox (Pilih/Batal Pilih Item)
  void toggleSelect(CartItem item) {
    item.selected = !item.selected;
    _saveCartLocally();
  }

  void removeFromCart(CartItem item) {
    items.remove(item);
    _saveCartLocally();
  }

  void clearCart() {
    items.clear();
    _saveCartLocally();
  }

  // FITUR BARU: Total Harga dan Item yang HANYA DIPILIH (selected = true)
  num get totalSelectedPrice {
    return items.where((i) => i.selected).fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalSelectedItems {
    return items.where((i) => i.selected).fold(0, (sum, item) => sum + item.quantity);
  }

  // SET BUY NOW ITEM (Beli Langsung)
  void setBuyNow(ProductData product, ProductVariant? variant) {
    buyNowItem = CartItem(product: product, variant: variant, quantity: 1, selected: true);
  }

  void clearBuyNow() {
    buyNowItem = null;
  }

  // SIMPAN KERANJANG KE PENYIMPANAN HP (Sederhana via SharedPreferences)
  Future<void> _saveCartLocally() async {
    final prefs = await SharedPreferences.getInstance();
    // Untuk produksi, Anda perlu membuat fungsi toJson() di ProductData.
    // Di sini kita simpan flag sederhana agar keranjang tidak hilang.
    await prefs.setInt('cart_count', items.length); 
  }
}