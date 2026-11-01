import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../viewmodels/product_view_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductModel product;

  bool isDeleting = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  // UPDATE PRODUCT
  Future<void> updateProduct() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return UpdateProductDialog(product: product);
      },
    );

    if (result == null || !mounted) return;

    final price = double.tryParse(result[1]);

    if (price == null) return;

    final updatedProduct = ProductModel(
      id: product.id,
      documentId: product.documentId,
      title: result[0],
      price: price,
      description: product.description,
      category: product.category,
      image: product.image,
    );

    setState(() {
      isUpdating = true;
    });

    try {
      final provider = context.read<ProductProvider>();

      if (product.documentId != null) {
        // Firestore product update
        await provider.updateFirestoreProduct(
          product.documentId!,
          updatedProduct,
        );
      } else {
        // Fake Store API product update
        await provider.updateProduct(updatedProduct);
      }

      if (!mounted) return;

      setState(() {
        product = updatedProduct;
      });

      Navigator.pop(context, {
        'updated': true,
        'product': updatedProduct,
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update nahi hua: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  // DELETE PRODUCT
  Future<void> deleteProduct() async {
    if (isDeleting || isUpdating) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text(
            'Kya aap waqai is product ko delete karna chahte hain?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() {
      isDeleting = true;
    });

    try {
      final provider = context.read<ProductProvider>();

      if (product.documentId != null) {
        // Firestore product delete
        await provider.deleteFirestoreProduct(
          product.documentId!,
        );
      } else {
        // Fake Store API product delete
        await provider.deleteProduct(product.id);
      }

      if (!mounted) return;

      Navigator.pop(context, {
        'deleted': true,
        'id': product.id,
        'documentId': product.documentId,
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product delete nahi hua: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: product.image.startsWith('data:image')
                  ? Image.memory(
                base64Decode(product.image.split(',').last),
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 80,
                  );
                },
              )
                  : Image.network(
                product.image,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 80,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Text(
              product.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text('Category: ${product.category}'),

            const SizedBox(height: 15),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(product.description),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                    isUpdating || isDeleting
                        ? null
                        : updateProduct,
                    icon: const Icon(Icons.edit),
                    label: const Text('Update'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                    isDeleting || isUpdating
                        ? null
                        : deleteProduct,
                    icon: const Icon(Icons.delete),
                    label: Text(
                      isDeleting ? 'Deleting...' : 'Delete',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// UPDATE PRODUCT DIALOG

class UpdateProductDialog extends StatefulWidget {
  final ProductModel product;

  const UpdateProductDialog({
    super.key,
    required this.product,
  });

  @override
  State<UpdateProductDialog> createState() =>
      _UpdateProductDialogState();
}

class _UpdateProductDialogState
    extends State<UpdateProductDialog> {
  late TextEditingController titleController;
  late TextEditingController priceController;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.product.title,
    );

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void saveProduct() {
    final title = titleController.text.trim();

    final price = double.tryParse(
      priceController.text.trim(),
    );

    if (title.isEmpty || price == null || price <= 0) {
      setState(() {
        errorMessage =
        'Valid name aur positive price enter karein';
      });
      return;
    }

    Navigator.pop(context, [
      title,
      price.toString(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Product'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),

            TextField(
              controller: priceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: saveProduct,
          child: const Text('Update'),
        ),
      ],
    );
  }
}