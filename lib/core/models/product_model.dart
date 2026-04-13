class ProductListResponse {
  final List<ProductData> data;

  ProductListResponse({required this.data});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<ProductData> products = list.map((i) => ProductData.fromJson(i)).toList();
    return ProductListResponse(data: products);
  }
}

class ProductDetailResponse {
  final ProductData data;

  ProductDetailResponse({required this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      data: ProductData.fromJson(json['data']),
    );
  }
}

class ProductData {
  final String id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String type;
  final String status;
  final num price;
  final int soldCount;
  final ShopData shop; // Menggunakan Object ShopData
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  ProductData({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.soldCount,
    required this.shop,
    required this.images,
    required this.variants,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    var imageList = json['images'] as List? ?? [];
    var variantList = json['variants'] as List? ?? [];
    
    List<ProductVariant> parsedVariants = variantList.map((i) => ProductVariant.fromJson(i)).toList();

    // LOGIKA HARGA CERDAS: Cari harga > 0 dari price, min_price, atau varian
    num parsedPrice = num.tryParse(json['price']?.toString() ?? '0') ?? 0;
    if (parsedPrice == 0) {
      parsedPrice = num.tryParse(json['min_price']?.toString() ?? '0') ?? 0;
    }
    if (parsedPrice == 0 && parsedVariants.isNotEmpty) {
      parsedPrice = parsedVariants.first.price;
    }

    return ProductData(
      id: json['id'].toString(),
      name: json['name'] ?? 'Tanpa Nama',
      slug: json['slug'] ?? '',
      shortDescription: json['short_description'],
      description: json['description'],
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      price: parsedPrice, // Menggunakan harga yang sudah dicari
      soldCount: int.tryParse(json['sold_count']?.toString() ?? '0') ?? 0,
      shop: ShopData.fromJson(json['shop'] ?? {}),
      images: imageList.map((i) => ProductImage.fromJson(i)).toList(),
      variants: parsedVariants,
    );
  }
}

// CLASS BARU UNTUK TOKO
class ShopData {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final double rating;
  final int ratingCount;

  ShopData({required this.id, required this.name, required this.slug, this.logoUrl, required this.rating, required this.ratingCount});

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Siju Shop',
      slug: json['slug'] ?? '',
      logoUrl: json['logo_url'],
      rating: json['rating'] != null ? (num.tryParse(json['rating']['average']?.toString() ?? '0') ?? 0).toDouble() : 0.0,
      ratingCount: json['rating'] != null ? (int.tryParse(json['rating']['count']?.toString() ?? '0') ?? 0) : 0,
    );
  }
}

class ProductImage {
  final String id;
  final String imageUrl;

  ProductImage({required this.id, required this.imageUrl});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(id: json['id'].toString(), imageUrl: json['image_url'] ?? '');
  }
}

class ProductVariant {
  final String id;
  final String name;
  final num price;
  final int stock;

  ProductVariant({required this.id, required this.name, required this.price, required this.stock});

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: num.tryParse(json['price']?.toString() ?? '0') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
    );
  }
}