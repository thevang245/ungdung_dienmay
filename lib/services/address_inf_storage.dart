import 'package:shared_preferences/shared_preferences.dart';

class AddressStorage {
  static const _keyName = 'addr_name';
  static const _keyPhone = 'addr_phone';
  static const _keyEmail = 'addr_email';
  static const _keyCity = 'addr_city';
  static const _keyDistrict = 'addr_district';
  static const _keyStreet = 'addr_street';

  static Future<void> save({
    required String name,
    required String phone,
    required String email,
    required String city,
    required String district,
    required String street,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyCity, city);
    await prefs.setString(_keyDistrict, district);
    await prefs.setString(_keyStreet, street);
  }

  static Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'city': prefs.getString(_keyCity) ?? '',
      'district': prefs.getString(_keyDistrict) ?? '',
      'street': prefs.getString(_keyStreet) ?? '',
    };
  }
}
