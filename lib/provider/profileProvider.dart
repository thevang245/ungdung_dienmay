import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  String customerID = '';
  String customerName = '';
  String maKH = '';
  String email = '';
  String passwordHash = '';

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    customerID = prefs.getString('customerID') ?? '';
    customerName = prefs.getString('customerName') ?? '';
    maKH = prefs.getString('maKH') ?? '';
    email = prefs.getString('emailAddress') ?? '';
    passwordHash = prefs.getString('passWord') ?? '';
    notifyListeners();
  }

  Future<void> saveToPrefs({
    required String id,
    required String name,
    required String maKHValue,
    required String emailValue,
    required String passwordHashValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('customerID', id);
    await prefs.setString('customerName', name);
    await prefs.setString('maKH', maKHValue);
    await prefs.setString('emailAddress', emailValue);
    await prefs.setString('passWord', passwordHashValue);

    // Cập nhật provider
    isLoggedIn = true;
    customerID = id;
    customerName = name;
    maKH = maKHValue;
    email = emailValue;
    passwordHash = passwordHashValue;

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    isLoggedIn = false;
    customerID = '';
    customerName = '';
    maKH = '';
    email = '';
    passwordHash = '';

    notifyListeners();
  }
}
