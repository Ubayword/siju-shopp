import '../models/product_model.dart';

// Model untuk item di dalam keranjang
class CartItem {
  final ProductData product;
  final ProductVariant? variant;
  int quantity;

  CartItem({required this.product, this.variant, this.quantity = 1});

  // Ambil harga: Jika ada varian pakai harga varian, jika tidak pakai harga produk dasar
  num get price => variant != null && variant!.price > 0 ? variant!.price : product.price;
  
  // Total harga item ini (Harga * Jumlah)
  num get totalPrice => price * quantity;
}

// Service Singleton untuk menyimpan data keranjang secara global
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> items = [];

  void addToCart(ProductData product, ProductVariant? variant) {
    // Cek apakah produk dengan varian yang sama persis sudah ada di keranjang
    var existingItem = items.where((i) => i.product.id == product.id && i.variant?.id == variant?.id).toList();
    
    if (existingItem.isNotEmpty) {
      existingItem.first.quantity++; // Tambah kuantitas jika sudah ada
    } else {
      items.add(CartItem(product: product, variant: variant)); // Masukkan barang baru
    }
  }

  void removeFromCart(CartItem item) {
    items.remove(item);
  }

  void clearCart() {
    items.clear();
  }

  // Hitung subtotal seluruh keranjang
  num get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}