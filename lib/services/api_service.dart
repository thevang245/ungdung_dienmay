import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class APIService {
  // static const String baseUrl = 'https://api-choixanh.onrender.com';
  static const String baseUrl = 'https://46c0edd4db3c.ngrok-free.app';
  static const String loginUrl = '$baseUrl/api/login.php';

  static Future<Map<String, dynamic>> fetchProductsByCategory({
    required int categoryId,
    required String ww2,
    required String product,
    required String extention,
    required String idfilter
  }) async {
    late Uri uri;

    if (categoryId == 0) {
      uri = Uri.parse('${baseUrl}/api/module.sanpham.trangchu.php').replace(
        queryParameters: {'id': '35279'},
      );
    } else {
      uri = Uri.parse('$baseUrl/api/$extention.$product.php?id').replace(
        queryParameters: {
          'id': categoryId.toString(),
          'sl': '10',
          'pageid': '1',
          'idfilter': idfilter
        },
      );
    }

    print(uri);
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List && decoded.isNotEmpty && decoded[0] is Map) {
          return decoded[
              0]; // trả nguyên cả phần tử đầu tiên (có tieude, data, ...)
        } else {
          print('Phản hồi không hợp lệ');
          return {};
        }
      } else {
        print('Lỗi server: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Lỗi kết nối hoặc xử lý API: $e');
      return {};
    }
  }

  static Future<List<dynamic>> getProductRelated({
    required String id,
    required String modelType,
    int sl = 10,
    int pageId = 1,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/module.$modelType.chitiet.lienquan.php',
      ).replace(
        queryParameters: {
          'id': id,
          'sl': sl.toString(),
          'pageid': pageId.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;

        try {
          final decoded = json.decode(body);

          if (decoded is List && decoded.isNotEmpty) {
            final first = decoded[0];
            if (first is Map && first.containsKey('data')) {
              return first['data'];
            } else {
              print('Không tìm thấy key "data" trong phần tử đầu tiên.');
              return [];
            }
          } else {
            print('Phản hồi không phải List hoặc List rỗng.');
            return [];
          }
        } catch (e) {
          print('Lỗi parse JSON: $e');
          return [];
        }
      } else {
        print('Lỗi server: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      return [];
    }
  }

  static Future<List<dynamic>> loadComments() async {
    final uri = Uri.parse('$baseUrl/ww2/module.tintuc.asp').replace(
      queryParameters: {
        'id': '35281',
      },
    );

    print('Link comment: $uri');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          final firstItem = decoded[0];
          if (firstItem is Map<String, dynamic>) {
            final dataList = firstItem['data'];
            if (dataList is List) {
              print('Số comment nhận được: ${dataList.length}');
              return dataList;
            }
          }
        }
        return [];
      } else {
        print('Lỗi server khi tải comment: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi gọi API loadComments: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> searchSanPham(
      String keyword) async {
    final uri = Uri.parse('${baseUrl}/api/search.sanpham.php');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': keyword}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'] ?? [];

          // Trả về List<Map<String, dynamic>> trực tiếp từ JSON
          return data.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id'].toString(),
              'name': item['tieude'] ?? '',
              'price': double.tryParse(item['gia'].toString()) ?? 0,
              'kieuhienthi': item['kieuhienthi'],
              'image': item['hinhdaidien'] ?? '',
              'quantity': 1,
              'isSelect': false,
              'categoryId':
                  int.tryParse(item['categoryId']?.toString() ?? '0') ?? 35001,
            };
          }).toList();
        } else {
          print('❌ API trả về lỗi: ${jsonData['message']}');
          return [];
        }
      } else {
        print('❌ Lỗi HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi kết nối hoặc phân tích JSON: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getBoLocByCatalog(String idCatalog) async {
    final uri = Uri.parse('$baseUrl/api/getfilter?IDCatalog=$idCatalog');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('⚠️ Lỗi khi gọi API lọc: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('❌ Lỗi kết nối API lọc: $e');
      return {};
    }
  }

  static Future<List<dynamic>> fetchBoLocChiTiet(String id) async {
    final url = Uri.parse('$baseUrl/api/getfilter?IDCatalog=$id');

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : [data];
    } else {
      throw Exception('Lỗi khi lấy bộ lọc chi tiết: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>?> fetchProductDetail(
      String baseUrl,
      String danhmuc,
      String productId,
      Function(List<String>) getDanhSachHinh) async {
    final int productIdInt = int.tryParse(productId) ?? 0;
    final String url =
        '$baseUrl/api/module.$danhmuc.chitiet.php?id=$productIdInt';
    print('Fetching product details from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String responseBody = response.body;
        responseBody = responseBody.replaceAll(RegExp(r',\s*,\s*'), ',');
        responseBody =
            responseBody.replaceAll(RegExp(r',\s*(?=\s*[\}\]])'), '');
        responseBody = responseBody.replaceAll(RegExp(r',\s*$'), '');

        final data = json.decode(responseBody);

        if (data is List && data.isNotEmpty) {
          final detail = data.first;
          return detail;
        } else {
          print('No data or data is not a list');
          return null;
        }
      } else {
        throw Exception('Error loading product details');
      }
    } catch (e) {
      print('API error: $e');
      return null;
    }
  }

  static Future<String?> fetchHtmlContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "<p>Không thể tải nội dung chi tiết.</p>";
      }
    } catch (e) {
      return "<p>Lỗi tải nội dung: $e</p>";
    }
  }

  // static Future<List<dynamic>> fetchFilteredProducts() async {
  //   final url = Uri.parse(
  //     '$baseUrl/ww2/module.laytimkiem.asp?id=&id2=&id3=,n12229,n12239&pageid=1',
  //   );

  //   print("url filter: $url");

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body);
  //       if (jsonData is List) {
  //         return jsonData; // Trả về danh sách sản phẩm
  //       } else {
  //         print('Dữ liệu không phải dạng danh sách');
  //         return [];
  //       }
  //     } else {
  //       print('Lỗi khi gọi API: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Lỗi ngoại lệ: $e');
  //     return [];
  //   }
  // }
}
