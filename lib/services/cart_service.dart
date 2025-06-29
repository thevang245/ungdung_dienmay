import 'dart:convert';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:http/http.dart' as http;

class APICartService {
  static Future<String?> addToCart({
    required String emailAddress,
    required String password,
    required int productId,
    required int quantity,
    required String moduleType,
    required ValueNotifier<int> cartitemCount,
  }) async {
    final uri = Uri.parse('${APIService.baseUrl}/api/add.product.php');

    final bodyData = {
      'ProductID': productId,
      'Quantity': quantity,
      'EmailAddress': emailAddress,
      'ModuleType': moduleType,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyData),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          cartitemCount.value += quantity;
          return null;
        } else {
          print('API trả về lỗi: ${responseData['message']}');
          return responseData['message'] ?? 'Thêm vào giỏ hàng thất bại';
        }
      } else {
        print('Lỗi máy chủ: ${response.statusCode}');
        return 'Lỗi máy chủ: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Không thể kết nối máy chủ: $e';
    }
  }

  static Future<bool> updateCartItemQuantity({
    required String emailAddress,
    required int productId,
    required int newQuantity,
  }) async {
    final uri = Uri.parse(
      '${APIService.baseUrl}/api/update.quantity.php',
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ProductID': productId,
          'EmailAddress': emailAddress,
          'Quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return true;
        } else {
          print('API trả về lỗi: ${jsonResponse['message']}');
          return false;
        }
      } else {
        print('Lỗi HTTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi kết nối khi cập nhật số lượng: $e');
      return false;
    }
  }

  static Future<List<CartItemModel>> fetchCartItemsById({
    required String emailAddress,
  }) async {
    final uri = Uri.parse('${APIService.baseUrl}/api/get.cart.php');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'EmailAddress': emailAddress}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];

          List<CartItemModel> items = data.map((item) {
            final id = item['ProductID'].toString();
            final name = item['Title'] ?? '';
            final price = double.tryParse(item['Price'].toString()) ?? 0;
            final moduleType = item['ModuleType'] ?? '';
            final image = item['Image'] ?? '';
            final quantity = int.tryParse(item['Quantity'].toString()) ?? 1;

            print('🛒 SP: $name | ID: $id | SL: $quantity');

            return CartItemModel(
              id: id,
              name: name,
              price: price,
              moduleType: moduleType,
              image: image,
              quantity: quantity,
              categoryId: int.tryParse(item['categoryId']?.toString() ?? '0') ??
                  0, // Thêm categoryId với giá trị mặc định
            );
          }).toList();

          return items;
        } else {
          print("❌ API trả về lỗi: ${jsonResponse['message']}");
          return [];
        }
      } else {
        print("❌ Lỗi máy chủ: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Lỗi kết nối hoặc parse JSON: $e");
      return [];
    }
  }

  static Future<bool> removeCartItem({
    required String emailAddress,
    required String productId,
    required ValueNotifier<int> cartitemCount,
  }) async {
    final uri = Uri.parse(
      '${APIService.baseUrl}/api/remove.product.php',
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ProductID': productId,
          'EmailAddress': emailAddress,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          cartitemCount.value =
              (cartitemCount.value > 0) ? cartitemCount.value - 1 : 0;
          return true;
        } else {
          print('API báo lỗi: ${jsonResponse['message']}');
          return false;
        }
      } else {
        print('Lỗi HTTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi kết nối khi xóa sản phẩm: $e');
      return false;
    }
  }

  static Future<void> datHang({
    required String moduletype,
    required String customerName,
    required String email,
    required String tel,
    required String address,
    String note = '',
    required double totalPrice,
    required List<CartItemModel> items, // <-- NEW
  }) async {
    final url = Uri.parse('${APIService.baseUrl}/api/order.php');

    final body = {
      'customer_name': customerName,
      'email': email,
      'tel': tel,
      'address': address,
      'note': note,
      'total_price': totalPrice.toString(),
      'items': items
          .map((item) => {
                'idpart': int.tryParse(item.id.toString()) ?? 0,
                'quantity': item.quantity,
                'price': item.price,
                'moduletype': item.moduleType
              })
          .toList(),
    };

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Đặt hàng thành công!');
    } else {
      print('Đặt hàng lỗi!');
      throw Exception('Đặt hàng thất bại');
    }
  }

  static Future<String?> cancelOrder({
    required String orderId,
    required String emailAddress,
  }) async {
    final uri = Uri.parse('${APIService.baseUrl}/api/cancel.order.php');

    final bodyData = {
      'IDBG': orderId,
      'email': emailAddress,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          print('Hủy đơn thành công');
          return null; // null nghĩa là không có lỗi
        } else {
          print('API trả về lỗi: ${responseData['message']}');
          return responseData['message'] ?? 'Hủy đơn hàng thất bại';
        }
      } else {
        print('Lỗi máy chủ: ${response.statusCode}');
        return 'Lỗi máy chủ: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Không thể kết nối máy chủ: $e';
    }
  }

  static Future<int> getCartItemCountFromApi(String email) async {
    final response = await http.post(
      Uri.parse('${APIService.baseUrl}/api/get.total.quantity.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('dữ liệu tổng số lượng: $data');
      return int.tryParse(data['totalQuantity'].toString()) ?? 0;
    } else {
      throw Exception('Không thể lấy số lượng sản phẩm trong giỏ');
    }
  }
}
