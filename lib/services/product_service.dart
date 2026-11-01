
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'https://fakestoreapi.com';

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // 1. GET: Saare API products lana
  Future<List<ProductModel>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Products load nahi huay');
    }
  }

  // 2. GET: Single API product lana
  Future<ProductModel> getSingleProduct(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('Product nahi mila');
    }
  }

  // 3. GET: Categories lana
  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/categories'),
    );

    if (response.statusCode == 200) {
      return List<String>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('Categories load nahi huin');
    }
  }

  // 4. GET: Category ke products lana
  Future<List<ProductModel>> getProductsByCategory(
      String category,
      ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/category/${Uri.encodeComponent(category)}',
      ),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Category products load nahi huay');
    }
  }

  // 5. STEP 3: Image Firebase Storage par upload karna aur URL hasil karna
  Future<String> uploadProductImage(Uint8List imageBytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = FirebaseStorage.instance
        .ref()
        .child('products')
        .child(fileName);

    final uploadTask = ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // 5 seconds timeout taake user ko wait na karna pare
    final snapshot = await uploadTask.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        uploadTask.cancel();
        throw Exception(
          'Firebase Storage unavailable ya timeout (5s).',
        );
      },
    );

    final imageUrl = await snapshot.ref.getDownloadURL().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Download URL load nahi ho saka.');
      },
    );

    return imageUrl;
  }

  // 6. STEP 4: Product details aur image URL Firestore mein save karna
  Future<void> addProduct(ProductModel product) async {
    await firestore.collection('products').add({
      'title': product.title,
      'price': product.price,
      'description': product.description,
      'category': product.category,
      'image': product.image,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 7. READ: Firestore products live lana
  Stream<List<ProductModel>> getFirestoreProducts() {
    return firestore.collection('products').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return ProductModel(
            id: 0,
            documentId: doc.id,
            title: data['title'] ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            image: data['image'] ?? '',
          );
        }).toList();
      },
    );
  }

  // 8. READ: Category ke mutabiq Firestore products live lana
  Stream<List<ProductModel>> getFirestoreProductsByCategory(String category) {
    return firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return ProductModel(
          id: 0,
          documentId: doc.id,
          title: data['title'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          image: data['image'] ?? '',
        );
      }).toList();
    });
  }

  // 8. UPDATE: Firestore product update karna
  Future<void> updateFirestoreProduct(
      String documentId,
      ProductModel product,
      ) async {
    await firestore
        .collection('products')
        .doc(documentId)
        .update({
      'title': product.title,
      'price': product.price,
      'description': product.description,
      'category': product.category,
      'image': product.image,
    });
  }

  // 9. DELETE: Firestore product delete karna
  Future<void> deleteFirestoreProduct(
      String documentId,
      ) async {
    await firestore
        .collection('products')
        .doc(documentId)
        .delete();
  }

  // 10. PUT: FakeStore API product update
  Future<void> updateProduct(ProductModel product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category,
        'image': product.image,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Product update nahi hua');
    }
  }

  // 11. DELETE: FakeStore API product delete request
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
    );                                         

    if (response.statusCode != 200) {
      throw Exception('Product delete nahi hua');
    }
  }

  // 12. API product ki deleted ID Firestore mein save karna
  Future<void> saveDeletedApiProduct(int id) async {
    await firestore
        .collection('deleted_api_products')
        .doc(id.toString())
        .set({
      'productId': id,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // 13. Firestore se deleted API product IDs load karna
  Future<Set<int>> getDeletedApiProductIds() async {
    final snapshot = await firestore
        .collection('deleted_api_products')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return (data['productId'] as num).toInt();
    }).toSet();
  }
}
