import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class HomeProvider extends ChangeNotifier {
  bool isLoading = true;
  int categoryId = 0;
  List<dynamic> products = [];
  String categoryName = '';
  String idCatalogInitial = '';
  String selectedFilterString = '';
  List<int> dynamicCategoryIds = [];
  Map<String, dynamic> danhMucData = {};

  bool _hasLoadedProducts = false;
  bool get hasLoadedProducts => _hasLoadedProducts;

  Map<int, List<dynamic>> _cachedProducts = {};
  Map<int, int> _cachedRecordsTotal = {};

  Future<void> loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    Global.name = prefs.getString('customerName') ?? '';
    Global.email = prefs.getString('emailAddress') ?? '';
    Global.pass = prefs.getString('passWord') ?? '';
  }

  Future<void> fetchDanhMuc() async {
    try {
      final url = Uri.parse('${APIService.baseUrl}/ww2/app.menu.dautrang.${APIService.language}');
      print("url: ${url}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final rawList = jsonBody[0]['data'] ?? [];

        dynamicCategoryIds = rawList.map<int>((item) {
          return int.tryParse(item['id'].toString()) ?? 0;
        }).toList();

        danhMucData = {
          for (var item in rawList) item['id']: item,
        };

        notifyListeners();
      }
    } catch (e) {
      print('Lỗi fetch danh mục: $e');
    }
  }

  String findCategoryNameById(Map<dynamic, dynamic> data, int id,
      {bool parentOnly = true}) {
    for (var entry in data.entries) {
      final value = entry.value;
      if (value is Map && int.tryParse(value['id'].toString()) == id) {
        return value['tieude'] ?? '';
      }
      if (value is Map && value['children'] is List) {
        for (var child in value['children']) {
          if (child is Map && int.tryParse(child['id'].toString()) == id) {
            return parentOnly
                ? (value['tieude'] ?? '')
                : (child['tieude'] ?? '');
          }
        }
      }
    }
    return '';
  }

  Future<void> fetchProducts({bool force = false}) async {
    print('Bắt đầu fetchProductsSmart cho category $categoryId');

    final now = DateTime.now().millisecondsSinceEpoch;
    const throttleMs = 60 * 1000; // throttle chỉ áp dụng cho API full
    final lastUpdateKey = '_lastUpdate_$categoryId';

    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(lastUpdateKey) ?? 0;

    // 1. Hiển thị cache ngay nếu có
    if (_cachedProducts.containsKey(categoryId) && !force) {
      products = _cachedProducts[categoryId]!;
      isLoading = false;
      notifyListeners();
      print('Hiển thị cache ngay cho category $categoryId');
    } else {
      isLoading = true;
      notifyListeners();
    }

    try {
    
      if (categoryId == 35001) {
        List<Map<String, dynamic>> allProductsCombined = [];

        for (var catId in dynamicCategoryIds) {
          final modules = categoryModules[catId];
          if (modules == null) continue;

          final fullResponse = await APIService.fetchProductsByCategory(
            ww2: modules[0],
            product: modules[1],
            extention: modules[2],
            categoryId: catId,
            idfilter: selectedFilterString,
            metaOnly: false,
          );

          final fetched = fullResponse['data'] ?? [];
          final mappedProducts = fetched.map<Map<String, dynamic>>((item) {
            final casted = Map<String, dynamic>.from(item);
            return {
              ...casted,
              'moduleType': modules[1],
              'categoryId': catId,
              'categoryTitle': fullResponse['tieude'],
            };
          }).toList();

          allProductsCombined.addAll(mappedProducts);
        }

      
        _cachedProducts[categoryId] = allProductsCombined;
        products = [...allProductsCombined];
        isLoading = false;
        notifyListeners();
        return;
      }

      final modules = categoryModules[categoryId];
      if (modules == null) return;

      final metaResponse = await APIService.fetchProductsByCategory(
        ww2: modules[0],
        product: modules[1],
        extention: modules[2],
        categoryId: categoryId,
        idfilter: selectedFilterString,
        metaOnly: true,
      );

      final newRecordsTotal = metaResponse['recordsTotal'] ?? 0;
      final oldRecordsTotal = _cachedRecordsTotal[categoryId];

      // 3. Nếu force hoặc recordsTotal khác hoặc chưa có cache → fetch full
      if (force ||
          oldRecordsTotal == null ||
          oldRecordsTotal != newRecordsTotal) {
        if (!force && now - lastUpdate < throttleMs) {
          print(
              'Trong throttle, nhưng recordsTotal đã thay đổi → vẫn fetch full');
        }

        // API full
        final fullResponse = await APIService.fetchProductsByCategory(
            ww2: modules[0],
            product: modules[1],
            extention: modules[2],
            categoryId: categoryId,
            idfilter: selectedFilterString,
            metaOnly: false);

        final fetched = fullResponse['data'] ?? [];
        final allProducts = fetched.map<Map<String, dynamic>>((item) {
          final casted = Map<String, dynamic>.from(item);
          return {
            ...casted,
            'moduleType': modules[1],
            'categoryId': categoryId,
            'categoryTitle': fullResponse['tieude'],
          };
        }).toList();

        _cachedProducts[categoryId] = allProducts;
        _cachedRecordsTotal[categoryId] = newRecordsTotal;
        products = [...allProducts];
        isLoading = false;
        notifyListeners();

        prefs.setInt(lastUpdateKey, now);
        print('Đã cập nhật cache và UI (recordsTotal thay đổi)');
      } else {
        print('recordsTotal không thay đổi → giữ nguyên cache');
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi fetchProductsSmart: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  void changeCategory(int newId) async {
    if (categoryId != newId) {
      categoryId = newId;

      // Nếu chưa có danh mục thì fetch trước
      if (danhMucData.isEmpty) {
        await fetchDanhMuc();
      }

      categoryName = findCategoryNameById(danhMucData, newId);
      print('Đã chọn danh mục: $categoryName');

      fetchProducts();
    }
  }

  Future<void> runSearch(String keyword) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await APIService.searchSanPham(keyword);
      products = result.map((item) {
        return {
          ...item,
          'categoryId': item['categoryId'] ?? 0,
          'hinhdaidien': item['image'] ?? '',
          'gia': item['price'] ?? 0.0,
          'tieude': item['name'] ?? 'Unknown',
          'moduleType': item['kieuhienthi'],
        };
      }).toList();
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    products = [];
    isLoading = false;
    notifyListeners();
  }

  void applyFilter(String idFilter) {
    selectedFilterString = idFilter;
    isLoading = true;
    _hasLoadedProducts = false;
    fetchProducts();
    notifyListeners();
  }
}
