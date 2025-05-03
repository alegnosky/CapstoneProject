import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class EncryptedSecureStorage {
  static final _storage = FlutterSecureStorage();
  static const String _passwordsKey = "encrypted_passwords";
  static const String _masterHashKey = "master_password_hash";
  static const String _saltKey = "password_salt";
  static const String _ivKey = "encryption_iv";
  static const String _biometricsEnabledKey = "biometrics_enabled";
  static const String _bioProtectedMasterPassword =
      "bio_protected_master_password";
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isMasterPasswordSet() async {
    return await _storage.containsKey(key: _masterHashKey);
  }

  static Future<bool> setupMasterPassword(String masterPassword) async {
    try {
      final salt = encrypt.SecureRandom(16).base64;
      await _storage.write(key: _saltKey, value: salt);

      final hash = _hashPassword(masterPassword, salt);
      await _storage.write(key: _masterHashKey, value: hash);

      final iv = encrypt.IV.fromSecureRandom(16);
      await _storage.write(key: _ivKey, value: iv.base64);

      final encrypter = _getEncrypter(masterPassword, salt);
      final emptyData = encrypter.encrypt(jsonEncode({}), iv: iv).base64;
      await _storage.write(key: _passwordsKey, value: emptyData);
      return true;
    } catch (e) {
      print("Error setting master password: $e");
      return false;
    }
  }

  static Future<bool> verifyMasterPassword(String password) async {
    try {
      final storedHash = await _storage.read(key: _masterHashKey);
      final salt = await _storage.read(key: _saltKey);

      if (storedHash == null || salt == null) return false;

      final inputHash = _hashPassword(password, salt);
      return storedHash == inputHash;
    } catch (e) {
      print("Error verifying master password: $e");
      return false;
    }
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static encrypt.Encrypter _getEncrypter(String password, String salt) {
    final keySource = (password + salt);
    final keySourceBytes = utf8.encode(keySource);
    final digest = sha256.convert(keySourceBytes);
    final key = encrypt.Key(Uint8List.fromList(digest.bytes));
    return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  static encrypt.Encrypter _getBioEncrypter(String deviceId) {
    final keySource = utf8.encode("biometric_key_${deviceId}");
    final digest = sha256.convert(keySource);
    final key = encrypt.Key(Uint8List.fromList(digest.bytes));
    return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  static Future<void> setBiometricsEnabled(bool enabled, [String? masterPassword]) async {
    await _storage.write(key: _biometricsEnabledKey, value: enabled.toString());
    if (enabled && masterPassword != null){
      await storeMasterPasswordForBiometrics(masterPassword);
    }else if(!enabled){
      await _storage.delete(key: _bioProtectedMasterPassword);
      await _storage.delete(key: "${_bioProtectedMasterPassword}_iv");
    }
  }

  static Future<bool> isBiometricsEnabled() async {
    final enabled = await _storage.read(key: _biometricsEnabledKey);
    return enabled == 'true';
  }

  static Future<bool> canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print("Error checking biometrics: $e");
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access passwords',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Error authenticating biometrics: $e");
      return false;
    }
  }

  static Future<bool> storeMasterPasswordForBiometrics(
      String masterPassword) async {
    try {
      if (!await isBiometricsEnabled()) {
        return false;
      }
      final deviceId = await _getDeviceId();
      final encrypter = _getBioEncrypter(deviceId);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encryptedPassword =
          encrypter.encrypt(masterPassword, iv: iv).base64;

      await _storage.write(
          key: _bioProtectedMasterPassword, value: encryptedPassword);
      await _storage.write(
          key: "${_bioProtectedMasterPassword}_iv", value: iv.base64);
      return true;
    } catch (e) {
      print("Error storing master password for biometrics: $e");
      return false;
    }
  }

  static Future<String?> getMasterPasswordForBiometrics() async {
    try {
      if (!await isBiometricsEnabled()) {
        return null;
      }
      final encryptedPassword =
          await _storage.read(key: _bioProtectedMasterPassword);
      final ivString =
          await _storage.read(key: "${_bioProtectedMasterPassword}_iv");

      if (encryptedPassword == null || ivString == null) {
        return null;
      }
      final deviceId = await _getDeviceId();
      final encrypter = _getBioEncrypter(deviceId);
      final iv = encrypt.IV.fromBase64(ivString);
      return encrypter.decrypt64(encryptedPassword, iv: iv);
    } catch (e) {
      print("Error retrieving master password for biometrics: $e");
      return null;
    }
  }

  static Future<String> _getDeviceId() async {
    final salt = await _storage.read(key: _saltKey) ?? "default_salt";
    return salt;
  }

  static Future<bool> savePasswords(
      Map<String, String> passwords, String masterPassword) async {
    try {
      final salt = await _storage.read(key: _saltKey);
      final ivString = await _storage.read(key: _ivKey);

      if (salt == null || ivString == null) return false;

      final encrypter = _getEncrypter(masterPassword, salt);
      final iv = encrypt.IV.fromBase64(ivString);
      final encryptedData =
          encrypter.encrypt(jsonEncode(passwords), iv: iv).base64;
      await _storage.write(key: _passwordsKey, value: encryptedData);
      return true;
    } catch (e) {
      print("Error saving password: $e");
      return false;
    }
  }

  static Future<Map<String, String>> getPasswords(String masterPassword) async {
    try {
      final encryptedData = await _storage.read(key: _passwordsKey);
      final salt = await _storage.read(key: _saltKey);
      final ivString = await _storage.read(key: _ivKey);

      if (encryptedData == null || salt == null || ivString == null) {
        return {};
      }
      final encrypter = _getEncrypter(masterPassword, salt);
      final iv = encrypt.IV.fromBase64(ivString);
      final decryptedData = encrypter.decrypt64(encryptedData, iv: iv);
      return Map<String, String>.from(jsonDecode(decryptedData));
    } catch (e) {
      print("Error fetching password: $e");
      return {};
    }
  }

  static Future<bool> addPassword(
      String identifier, String password, String masterPassword) async {
    try {
      final passwords = await getPasswords(masterPassword);
      passwords[identifier] = password;
      return await savePasswords(passwords, masterPassword);
    } catch (e) {
      print("Failed to add password: $e");
      return false;
    }
  }

  static Future<bool> deletePassword(
      String identifier, String masterPassword) async {
    try {
      final passwords = await getPasswords(masterPassword);
      passwords.remove(identifier);
      return await savePasswords(passwords, masterPassword);
    } catch (e) {
      print("Failed to delete password: $e");
      return false;
    }
  }

  static Future<bool> changeMasterPassword(
      String oldPassword, String newPassword) async {
    try {
      if (!await verifyMasterPassword(oldPassword)) {
        return false;
      }
      final passwords = await getPasswords(oldPassword);
      await setupMasterPassword(newPassword);
      return await savePasswords(passwords, newPassword);
    } catch (e) {
      print("Failed to change passwords: $e");
      return false;
    }
  }
}
