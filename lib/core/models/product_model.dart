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
  final String? description;
  final String type;
  final String status;
  final int shopId;
  final int categoryId;
  final List<ProductVariant> variants;
  final dynamic specifications; // Bisa array atau object

  ProductData({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.type,
    required this.status,
    required this.shopId,
    required this.categoryId,
    required this.variants,
    this.specifications,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    // Mapping list variants dari JSON
    var list = json['variants'] as List? ?? [];
    List<ProductVariant> variantsList = list.map((i) => ProductVariant.fromJson(i)).toList();

    return ProductData(
      id: json['id'].toString(),
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      shopId: json['shop_id'] is int ? json['shop_id'] : int.parse(json['shop_id'].toString()),
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      variants: variantsList,
      specifications: json['specifications'],
    );
  }
}

class ProductVariant {
  final String id;
  final int productId;
  final String name;
  final String? sku;
  final num price; // Menggunakan num karena di JSON tipenya number
  final int stock;
  final String? imageUrl;
  final int version;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.sku,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.version,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'].toString(),
      productId: json['product_id'] is int ? json['product_id'] : int.parse(json['product_id'].toString()),
      name: json['name'],
      sku: json['sku'],
      // Handle parsing num aman
      price: json['price'] is num ? json['price'] : num.tryParse(json['price'].toString()) ?? 0,
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
      imageUrl: json['image_url'],
      version: json['version'] is int ? json['version'] : int.parse(json['version'].toString()),
    );
  }
}

class ProductListResponse {
  final List<ProductData> data;

  ProductListResponse({required this.data});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<ProductData> products = list.map((i) => ProductData.fromJson(i)).toList();

    return ProductListResponse(data: products);
  }
}