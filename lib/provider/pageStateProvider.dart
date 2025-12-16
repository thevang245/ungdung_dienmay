// lib/providers/page_state_provider.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class PageStateProvider extends ChangeNotifier {
  int currentIndex = 0;
  String currentPage = 'home';
  String previousPage = 'home';
  dynamic selectedProduct;
  List<dynamic> productDetailStack = [];
  int cartItemCount = 0;
  int selectedCategoryId = 35001;
  int filterVersion = 0;

  void setCurrentPage(String page) {
    currentPage = page;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void setCartItemCount(int count) {
    cartItemCount = count;
    notifyListeners();
  }

  void setSelectedCategory(int id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  void triggerFilter() {
    filterVersion++;
    notifyListeners();
  }

  void goToDetail(dynamic product) {
    if (selectedProduct != null) productDetailStack.add(selectedProduct);
    selectedProduct = product;
    previousPage = currentPage;
    currentPage = 'detail';
    notifyListeners();
  }

  void goBackFromDetail() {
    if (productDetailStack.isNotEmpty) {
      selectedProduct = productDetailStack.removeLast();
      notifyListeners();
    } else {
      selectedProduct = null;
      currentPage = previousPage;
      productDetailStack.clear();
      notifyListeners();
    }
  }
}
