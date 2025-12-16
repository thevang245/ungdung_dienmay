
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/order_history_model.dart';
import 'package:flutter_application_1/models/product_model.dart';

class DetailProvider extends ChangeNotifier {
  dynamic selectedProduct;
  String currentPage = 'home';
  String previousPage = 'home';
  final List<dynamic> _productDetailStack = [];

  void goToDetail(dynamic product, String fromPage, {bool isBack = false}) {
    String? currentId;
    String? newId;
    print('Da nhan detail');

    if (selectedProduct != null) {
      if (selectedProduct is CartItemModel) {
        currentId = selectedProduct.id;
      } else if (selectedProduct is Map) {
        currentId = selectedProduct['id'].toString();
      }
    }

    if (product is CartItemModel) {
      newId = product.id;
    } else if (product is Map<String, dynamic>) {
      newId = product['id']?.toString();
    } else if (product is OrderModel && product.items.isNotEmpty) {
      newId = product.items.first.id;
    }

    if (!isBack && fromPage != 'detail') {
      previousPage = fromPage;
    }

    if (!isBack &&
        currentPage == 'detail' &&
        currentId != null &&
        newId != null &&
        currentId != newId) {
      _productDetailStack.add(selectedProduct);
    }

    selectedProduct = product;
    currentPage = 'detail';
    notifyListeners();
  }

  void goBackFromDetail() {
    if (_productDetailStack.isNotEmpty) {
      final previousProduct = _productDetailStack.removeLast();
      goToDetail(previousProduct, 'detail', isBack: true);
    } else {
      currentPage = previousPage;
      selectedProduct = null;
      _productDetailStack.clear();
      notifyListeners();
    }
  }
}
