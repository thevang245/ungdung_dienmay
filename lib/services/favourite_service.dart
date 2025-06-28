import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:http/http.dart' as http;

class APIFavouriteService {
  static Future<bool> toggleFavourite({
    required BuildContext context,
    required String userId,
    required int productId,
    required String tieude,
    required String gia,
    required String hinhdaidien,
    required String moduleType, // 👈 Thêm tham số moduleType
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'favourite_items_$userId';
    List<String> favouriteItems = prefs.getStringList(key) ?? [];

    final itemMap = {
      'id': productId.toString(),
      'tieude': tieude,
      'gia': gia,
      'hinhdaidien': hinhdaidien,
      'moduleType': moduleType, // 👈 Thêm vào đây
    };

    bool exists = false;
    String? existingItem;

    for (var itemStr in favouriteItems) {
      try {
        final item = json.decode(itemStr);
        if (item['id'] == productId.toString()) {
          exists = true;
          existingItem = itemStr;
          break;
        }
      } catch (_) {}
    }

    if (exists && existingItem != null) {
      favouriteItems.remove(existingItem);
      await prefs.setStringList(key, favouriteItems);
      showToast('Đã xóa khỏi yêu thích');
      print('❌ Đã xóa khỏi yêu thích: $productId');
      return false;
    } else {
      favouriteItems.add(json.encode(itemMap));
      await prefs.setStringList(key, favouriteItems);
      showToast('Đã thêm vào yêu thích');
      print('❤️ Đã thêm vào yêu thích: $productId');
      return true;
    }
  }
}