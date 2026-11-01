class ProductModel {
  final int id;
  final String? documentId;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  ProductModel({
    required this.id,
    this.documentId,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      documentId: json['documentId']?.toString(),
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
    );
  }
}