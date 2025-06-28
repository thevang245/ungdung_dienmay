import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/allpage.dart';
import 'package:flutter_application_1/view/auth/login.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>?> _login(
      String username, String password) async {
    try {
      final Uri url = Uri.parse(APIService.loginUrl);
      print('urllogin $url');
      print('username: $username, password: $password');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] != null) {
          return body['data'];
        } else {
          print('Lỗi đăng nhập: ${body['message']}');
          return null;
        }
      } else {
        print('Lỗi server: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return null;
    }
  }

// Hàm chuyển password thành MD5
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static Future<void> handleLogin(
      BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      showToast('Vui lòng nhập đầy đủ thông tin', backgroundColor: Colors.red);
      return;
    }

    var userData = await _login(username, password);

    if (userData != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('customerID', userData['CustomerID'].toString());
      await prefs.setString('customerName', userData['CustomerName'] ?? '');
      await prefs.setString('maKH', userData['MaKH'] ?? '');
      await prefs.setString('emailAddress', username);
      await prefs.setString('passWord', generateMd5(password));

      final passw = prefs.getString('pass');
      print('Đăng nhập thành công: $username && mật khẩu MD5: $passw');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PageAll()),
      );
    } else {
      showToast('Đăng nhập thất bại', backgroundColor: Colors.red);
    }
  }

  // Hàm logout
  static Future<void> handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Xóa dữ liệu
    await prefs.remove('isLoggedIn');
    await prefs.remove('emailAddress');
    await prefs.remove('passWord');
    await prefs.remove('customerName');

    // Reset global biến
    Global.name = '';
    Global.email = '';
    Global.pass = '';

    // In log ra console
    print('== Đã đăng xuất và xóa dữ liệu ==');
    print('isLoggedIn: ${prefs.getBool('isLoggedIn')}');
    print('emailAddress: ${prefs.getString('emailAddress')}');
    print('passWord: ${prefs.getString('passWord')}');
    print('customerName: ${prefs.getString('customerName')}');

    print('Global.name: ${Global.name}');
    print('Global.email: ${Global.email}');
    print('Global.pass: ${Global.pass}');
  }

  // Kiểm tra đã login chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Lấy userid đã lưu
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emailAddress') ?? '';
  }

  // Lấy password đã lưu
  static Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('passWord') ?? '';
  }
}
