import 'dart:convert';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCartService {
  static const String _cartKey = 'cart_items';

  /// Lấy toàn bộ giỏ hàng
  static Future<List<CartItemModel>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cartKey);

    if (data == null) return [];

    final List list = json.decode(data);
    return list.map((e) => CartItemModel.fromJson(e)).toList();
  }

  /// Thêm hoặc tăng số lượng
 static Future<void> addToCart(CartItemModel item) async {
  final prefs = await SharedPreferences.getInstance();
  final items = await getCartItems();

  final index = items.indexWhere(
    (e) => e.id == item.id && e.moduleType == item.moduleType,
  );

  if (index != -1) {
    items[index].quantity += item.quantity;
    print('🟡 Tăng số lượng sản phẩm: ${items[index].id}');
  } else {
    items.add(item);
    print('🟢 Thêm sản phẩm mới vào giỏ: ${item.id}');
  }

  final jsonData = json.encode(
    items.map((e) => e.toJson()).toList(),
  );

  await prefs.setString(_cartKey, jsonData);

  // 🔍 PRINT KIỂM TRA
  print('========== CART SAVED ==========');
  print(jsonData);

  // In từng item cho dễ nhìn
  for (final e in items) {
    print(
      'ID: ${e.id} | '
      'Tên: ${e.name} | '
      'SL: ${e.quantity} | '
      'Giá: ${e.price} | '
      'Module: ${e.moduleType} | '
      'Category: ${e.categoryId}',
    );
  }
  print('================================');
}


  /// Cập nhật số lượng
  static Future<void> updateQuantity(String id, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getCartItems();

    final index = items.indexWhere((e) => e.id == id);
    if (index != -1) {
      items[index].quantity = quantity;
    }

    await prefs.setString(
      _cartKey,
      json.encode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Xóa 1 sản phẩm
  static Future<void> removeItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getCartItems();

    items.removeWhere((e) => e.id == id);

    await prefs.setString(
      _cartKey,
      json.encode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Tổng số lượng (badge)
  static Future<int> getTotalQuantity() async {
    final List<CartItemModel> items = await getCartItems();
    return items.fold<int>(0, (int sum, CartItemModel e) {
      return sum + (e.quantity);
    });
  }

  /// Clear giỏ
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
