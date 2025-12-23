import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:http/http.dart' as http;

class APIFavouriteService {
  static Future<bool> toggleFavourite({
    required int productId,
    required String tieude,
    required String gia,
    required String hinhdaidien,
    required String moduleType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'favourite_items';

    List<String> favouriteItems = prefs.getStringList(key) ?? [];

    final itemMap = {
      'id': productId.toString(),
      'tieude': tieude,
      'gia': gia,
      'hinhdaidien': hinhdaidien,
      'moduleType': moduleType,
    };

    bool exists = false;
    String? existingItem;

    for (final itemStr in favouriteItems) {
      try {
        final item = json.decode(itemStr);
        final itemId = item['id'].toString(); 

        if (itemId == productId.toString()) {
          exists = true;
          existingItem = itemStr;
          break;
        }
      } catch (e) {
        print('JSON error: $e');
      }
    }

    if (exists && existingItem != null) {
      favouriteItems.remove(existingItem);
      await prefs.setStringList(key, favouriteItems);
      showToast('Đã xóa khỏi yêu thích');
      return false;
    } else {
      favouriteItems.add(json.encode(itemMap));
      await prefs.setStringList(key, favouriteItems);
      showToast('Đã thêm vào yêu thích');
      return true;
    }
  }
}
