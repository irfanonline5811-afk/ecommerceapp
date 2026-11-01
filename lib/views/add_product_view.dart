import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../viewmodels/product_view_model.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final ProductService service = ProductService();
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();

  String category = 'electronics';
  bool isLoading = false;

  Uint8List? selectedImageBytes;

  final List<String> categories = [
    'electronics',
    'jewelery',
    "men's clothing",
    "women's clothing",
  ];

  // Gallery se image select karna
  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 65,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image select nahi hui: $e'),
        ),
      );
    }
  }

  // Product add karna
  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final manualUrl = imageUrlController.text.trim();

    if (selectedImageBytes == null && manualUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gallery se image select karein ya Image URL likhein',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String finalImageUrl = '';

      // Agar user ne Image URL diya hai
      if (manualUrl.isNotEmpty) {
        finalImageUrl = manualUrl;
      }

      // Agar gallery se image select ki hai
      else if (selectedImageBytes != null) {
        try {
          finalImageUrl = await service.uploadProductImage(
            selectedImageBytes!,
          );
        } catch (storageError) {
          debugPrint('Storage error: $storageError');

          finalImageUrl =
          'data:image/jpeg;base64,${base64Encode(selectedImageBytes!)}';
        }
      }

      // Product Model banana
      final product = ProductModel(
        id: 0,
        title: titleController.text.trim(),
        price: double.parse(priceController.text.trim()),
        description: descriptionController.text.trim(),
        category: category,
        image: finalImageUrl,
      );

      // Provider ke through Firestore mein save karna
      await context.read<ProductProvider>().addProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product successfully added!'),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product add nahi hua: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 7),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // Product Name
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name likhein';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Price
              TextFormField(
                controller: priceController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (price == null || price <= 0) {
                    return 'Valid price likhein';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description likhein';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Image URL
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),

              const SizedBox(height: 10),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'YA',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 10),

              // Gallery Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image from Gallery'),
                ),
              ),

              const SizedBox(height: 10),

              // Image Preview
              if (selectedImageBytes != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        selectedImageBytes!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

                    IconButton(
                      icon: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedImageBytes = null;
                        });
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 15),

              // Category
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 25),

              // Add Product Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text('Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}