import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static const String _key = "saved_passwords";

  static Future<void> savePassword(String identifier, String password) async {
    String? storedPasswords = await _storage.read(key: _key);
    Map<String, String> passwords = storedPasswords != null
        ? Map<String, String>.from(jsonDecode(storedPasswords))
        : {};

    passwords[identifier] = password;
    await _storage.write(key: _key, value: jsonEncode(passwords));
  }

  static Future<Map<String, String>> getPasswords() async {
    String? storedPasswords = await _storage.read(key: _key);
    if (storedPasswords == null) return {};
    return Map<String, String>.from(jsonDecode(storedPasswords));
  }

  static Future<void> deletePassword(String identifier) async {
    String? storedPasswords = await _storage.read(key: _key);
    if (storedPasswords == null) return;
    Map<String, String> passwords =
        Map<String, String>.from(jsonDecode(storedPasswords));
    passwords.remove(identifier);

    await _storage.write(key: _key, value: jsonEncode(passwords));
  }
}
