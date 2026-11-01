import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../viewmodels/product_view_model.dart';
import '../widgets/product_card.dart';

import 'category_view.dart';
import 'product_detail_view.dart';
import 'add_product_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // API se update kiye gaye products
  final Map<int, ProductModel> updatedProducts = {};

  // Delete kiye gaye API products ki IDs
  final Set<int> deletedApiProductIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      loadDeletedProducts();
    });
  }

  // Deleted API products ki IDs load karna
  Future<void> loadDeletedProducts() async {
    try {
      final ids = await context
          .read<ProductProvider>()
          .fetchDeletedApiProductIds();

      if (!mounted) return;

      setState(() {
        deletedApiProductIds.addAll(ids);
      });
    } catch (e) {
      debugPrint('Deleted IDs load error: $e');
    }
  }

  // Products refresh karna
  Future<void> refreshProducts() async {
    await context.read<ProductProvider>().fetchProducts();
    await loadDeletedProducts();
  }

  // Product detail views open karna
  Future<void> openProduct(ProductModel product) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );

    if (!mounted || result == null || result is! Map) {
      return;
    }

    // Product update
    if (result['updated'] == true) {
      final updatedProduct = result['product'];

      if (updatedProduct is ProductModel) {
        if (updatedProduct.documentId == null) {
          // API product update
          setState(() {
            updatedProducts[updatedProduct.id] = updatedProduct;
          });
        } else {
          // Firestore product update
          // Firestore StreamBuilder khud updated data show karega.
        }
      }
    }

    // Product delete
    if (result['deleted'] == true) {
      final documentId = result['documentId'];
      final id = result['id'];

      if (documentId != null) {
        // Firestore stream automatically deleted product remove karegi.
      } else if (id is int) {
        // API deleted product ko list se hide karna
        setState(() {
          deletedApiProductIds.add(id);
          updatedProducts.remove(id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Store'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: context.read<ProductProvider>().firestoreProducts,
        builder: (context, firestoreSnapshot) {
          if (firestoreSnapshot.hasError) {
            return Center(
              child: Text(
                'Firestore error: ${firestoreSnapshot.error}',
              ),
            );
          }

          if (firestoreSnapshot.connectionState ==
              ConnectionState.waiting &&
              !firestoreSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final firestoreProducts =
              firestoreSnapshot.data ?? <ProductModel>[];

          return Consumer<ProductProvider>(
            builder: (context, provider, child) {
              // Loading
              if (provider.isLoading &&
                  provider.products.isEmpty &&
                  firestoreProducts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // API error
              if (provider.error != null &&
                  provider.products.isEmpty &&
                  firestoreProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('API error: ${provider.error}'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: refreshProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // API products filter karna
              final displayedApiProducts = provider.products
                  .where(
                    (item) =>
                !deletedApiProductIds.contains(item.id),
              )
                  .map(
                    (item) => updatedProducts[item.id] ?? item,
              )
                  .toList();

              // Firestore + API products combine karna
              final products = [
                ...firestoreProducts,
                ...displayedApiProducts,
              ];

              // Agar koi product nahi hai
              if (products.isEmpty) {
                return RefreshIndicator(
                  onRefresh: refreshProducts,
                  child: ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text('Koi product nahi mila.'),
                      ),
                    ],
                  ),
                );
              }

              // Products Grid
              return RefreshIndicator(
                onRefresh: refreshProducts,
                child: GridView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
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
                      key: ValueKey(
                        product.documentId ?? 'api_${product.id}',
                      ),
                      product: product,
                      onTap: () => openProduct(product),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // Add Product Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryPage(),
              ),
            );
          }
        },
      ),
    );
  }
}