import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comments_model.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class APIService {
  static const String baseUrl = 'https://vangtran.125.atoz.vn';
  static const String language = 'ashx';
  static const String type1 = 'ww1';
  static const String type2 = 'ww2';
  static const String loginUrl = '$baseUrl/${type2}/login.${language}';

  static Future<Map<String, dynamic>> fetchProductsByCategory({
    required int categoryId,
    required String ww2,
    required String product,
    required String extention,
    required String idfilter,
    required bool metaOnly,
  }) async {
    late Uri uri;

    if (categoryId == 0) {
      uri = Uri.parse(
        '$baseUrl/${type2}/module.sanpham.trangchu.$language',
      ).replace(
        queryParameters: {'id': '35279'},
      );
    } else {
      uri = Uri.parse(
        '$baseUrl/${type2}/$extention.$product.$language',
      ).replace(
        queryParameters: {
          'id': categoryId.toString(),
          'sl': '10',
          'pageid': '1',
          'idfilter': idfilter,
        },
      );
    }

    print("url lay san pham: $uri");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List && decoded.isNotEmpty && decoded[0] is Map) {
          return decoded[0];
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
        '$baseUrl/${type2}/module.$modelType.chitiet.lienquan.${language}',
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
    final uri = Uri.parse('$baseUrl/${type2}/module.tintuc.asp').replace(
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
    final uri = Uri.parse('${baseUrl}/${type2}/search.sanpham.${language}');
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

  static Future<Map<String, dynamic>> getBoLocByCatalog(
      String idCatalog) async {
    final uri = Uri.parse('$baseUrl/${type2}/getfilter?IDCatalog=$idCatalog');

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
    final url = Uri.parse('$baseUrl/${type2}/getfilter?IDCatalog=$id');

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
        '$baseUrl/${type2}/module.$danhmuc.chitiet.${language}?id=$productIdInt';
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
  //     '$baseUrl/${type2}/module.laytimkiem.asp?id=&id2=&id3=,n12229,n12239&pageid=1',
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

  static Future<List<Comment>> fetchComments(int id) async {
    final url = Uri.parse('${baseUrl}/${type2}/binhluan.pc.${language}?id=$id');
    print('Fetching comments from: $url');

    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body);

      if (responseData is List && responseData.isNotEmpty) {
        final firstElement = responseData[0] as Map<String, dynamic>;
        final commentList = firstElement['data'] as List<dynamic>;
        return commentList.map((e) => Comment.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

///// API COMMMENTS
  static Future<String> _getAntiBotToken() async {
    print('➡️ [PRECHECK] Gọi recapcha.precheck');

    final res = await http.post(
      Uri.parse(
        '${baseUrl}/ww1/recapcha.precheck.ashx',
      ),
      body: {
        'action': 'comment',
        'hasread': '1',
      },
    );

    print('statusCode = ${res.statusCode}');
    print('body = ${res.body}');

    final data = jsonDecode(res.body);

    if (data is! List || data.isEmpty) {
      throw Exception('Precheck trả về dữ liệu không hợp lệ');
    }

    if (data[0]['maloi'] != '0') {
      throw Exception(
        'Precheck fail: ${data[0]['ThongBao'] ?? 'Unknown error'}',
      );
    }

    final token = data[0]['AntiBotToken'];
    print('AntiBotToken = $token');

    return token;
  }

  static Future<Map<String, dynamic>> sendComments({
    required String idPart,
    required String tenkh,
    required String sdt,
    required String email,
    required String noidung,
    double sosao = 0,
    int? l,
    String hinhdaidien = '/dist/images/user.jpg',
    String aitrain = '',
  }) async {
    try {
      final antiBotToken = await _getAntiBotToken();
      print('idcommentparent: $l');

      final Map<String, String> body = {
        'tenkh': tenkh,
        'txtemail': email,
        'txtdienthoai': sdt,
        'noidungtxt': noidung,
        'id3': hinhdaidien,
        'AntiBotToken': antiBotToken,
        'aitrain': aitrain,
      };

      if (l != null && l > 0) {
        body['l'] = l.toString();
        body['id2'] = '0';
      } else if (sosao > 0) {
        final int star = sosao.round().clamp(1, 5);
        body['id2'] = star.toString();
      }

      final res = await http.post(
        Uri.parse(
          '${baseUrl}/ww1/save.binhluan.ashx?id=$idPart',
        ),
        body: body,
      );

      final data = jsonDecode(res.body);
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data[0]);
      }

      return {'maloi': '-1', 'ThongBao': 'No response'};
    } catch (e) {
      return {'maloi': '-1', 'ThongBao': e.toString()};
    }
  }

  static Future<void> likeComment({
    required int postId,
    required int? commentId,
  }) async {
    try {
      final antiBotToken = await _getAntiBotToken();

      print('AntiBotToken = $antiBotToken');
      print('postid = $postId');
      print('commentID = $commentId');

      final res = await http.post(
        Uri.parse(
          '${baseUrl}/ww1/save.binhluan.thich.ashx'
          '?id=$postId&id2=$commentId',
        ),
        body: {
          'AntiBotToken': antiBotToken,
        },
      );

      print('statusCode = ${res.statusCode}');
      print('body = ${res.body}');

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);

       
        if (data is Map && data['maloi']?.toString() == '1') {
          print('Like comment thành công');
          return;
        }

        throw Exception(data['ThongBao'] ?? 'Like thất bại');
      }

      throw Exception('HTTP error ${res.statusCode}');
    } catch (e) {
      print('[LIKE] Lỗi: $e');
      rethrow;
    }
  }
}
