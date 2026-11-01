import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // API se saare products load karna
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getAllProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Firestore se saved products live load karna
  Stream<List<ProductModel>> get firestoreProducts {
    return _service.getFirestoreProducts();
  }

  // Naya product Firestore mein save karna
  Future<void> addProduct(ProductModel product) async {
    await _service.addProduct(product);
    notifyListeners();
  }

  // Firestore mein product update karna
  Future<void> updateFirestoreProduct(
      String documentId,
      ProductModel product,
      ) async {
    await _service.updateFirestoreProduct(documentId, product);
    notifyListeners();
  }

  // Firestore se product delete karna
  Future<void> deleteFirestoreProduct(String documentId) async {
    await _service.deleteFirestoreProduct(documentId);
    notifyListeners();
  }

  // Fake Store API se single product load karna
  Future<ProductModel> fetchSingleProduct(int id) {
    return _service.getSingleProduct(id);
  }

  // Fake Store API se categories load karna
  Future<List<String>> fetchCategories() {
    return _service.getCategories();
  }

  // Fake Store API se category ke products load karna
  Future<List<ProductModel>> fetchProductsByCategory(
      String category,
      ) {
    return _service.getProductsByCategory(category);
  }

  // Fake Store API se product update karna
  Future<void> updateProduct(ProductModel product) async {
    await _service.updateProduct(product);
    notifyListeners();
  }

  // Fake Store API se product delete karna
  Future<void> deleteProduct(int id) async {
    await _service.deleteProduct(id);
    await _service.saveDeletedApiProduct(id);
    notifyListeners();
  }

  // Firestore mein deleted API product IDs load karna
  Future<Set<int>> fetchDeletedApiProductIds() async {
    return await _service.getDeletedApiProductIds();
  }
}