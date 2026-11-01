
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_view.dart';

class ProductsByCategoryPage extends StatefulWidget {
  final String category;

  const ProductsByCategoryPage({
    super.key,
    required this.category,
  });

  @override
  State<ProductsByCategoryPage> createState() =>
      _ProductsByCategoryPageState();
}

class _ProductsByCategoryPageState
    extends State<ProductsByCategoryPage> {
  final ProductService service = ProductService();

  late Future<List<ProductModel>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture =
        service.getProductsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<ProductModel>>(
        // 1. Firestore se is category ke realtime products lana
        stream: service.getFirestoreProductsByCategory(widget.category),
        builder: (context, firestoreSnapshot) {
          final firestoreProducts = firestoreSnapshot.data ?? [];

          // 2. FakeStore API se is category ke products lana
          return FutureBuilder<List<ProductModel>>(
            future: productsFuture,
            builder: (context, apiSnapshot) {
              if (firestoreSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  apiSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final apiProducts = apiSnapshot.data ?? [];

              // 3. Combine: Pehle Firestore ke naye products, phir API products
              final products = [
                ...firestoreProducts,
                ...apiProducts,
              ];

              if (products.isEmpty) {
                return const Center(
                  child: Text('Is category mein koi product nahi hai.'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                            product: product,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
