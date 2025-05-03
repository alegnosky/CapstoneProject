import 'package:get/get.dart';
import 'package:vpn_capstone/passwordServices/encryptedPasswordStorage.dart';
import 'package:vpn_capstone/passwordServices/passwordGenerator.dart';

class PasswordController extends GetxController {
  final RxMap<String, String> savedPasswords = <String, String>{}.obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool useBiometrics = false.obs;
  final RxString generatedPassword = ''.obs;
  String _masterPassword = '';

  @override
  void onInit() {
    super.onInit();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    useBiometrics.value = await EncryptedSecureStorage.isBiometricsEnabled();
  }

  void setMasterPassword(String password) {
    _masterPassword = password;
  }

  void setAuthenticated(bool value) {
    isAuthenticated.value = value;

    if (value) {
      loadPasswords();
    } else {
      savedPasswords.clear();
      _masterPassword = '';
    }
  }

  void generatePassword({int length = 32}) {
    generatedPassword.value = PasswordGenerator.generate(length: length);
  }

  Future<void> generatePassphrase({int wordCount = 4, String separator = '-'}) async{
    generatedPassword.value = await PasswordGenerator.generatePassPhrase(wordCount: wordCount, separator: separator);
  }

  Future<void> loadPasswords() async {
    if (_masterPassword.isEmpty) return;
    try {
      final passwords =
          await EncryptedSecureStorage.getPasswords(_masterPassword);
      savedPasswords.value = passwords;
    } catch (e) {
      Get.snackbar("Error", "Failed to load: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> savePassword(String identifier, String password) async {
    if (_masterPassword.isEmpty || identifier.isEmpty || password.isEmpty)
      return false;
    try {
      final success = await EncryptedSecureStorage.addPassword(
          identifier, password, _masterPassword);
      if (success) {
        await loadPasswords();
      }
      return success;
    } catch (e) {
      Get.snackbar("Error", "Failed to save password: $e",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> deletePassword(String identifier) async {
    if (_masterPassword.isEmpty || identifier.isEmpty) return false;
    try {
      final success = await EncryptedSecureStorage.deletePassword(
          identifier, _masterPassword);
      if (success) {
        await loadPasswords();
      }
      return success;
    } catch (e) {
      Get.snackbar("Error", "Failed to delete password: $e",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> changeMasterPassword(
      String oldPassword, String newPassword) async {
    try {
      final success = await EncryptedSecureStorage.changeMasterPassword(
          oldPassword, newPassword);
      if (success) {
        _masterPassword = newPassword;
        await loadPasswords();
      }
      return success;
    } catch (e) {
      Get.snackbar("Error", "Failed to change password: $e",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> toggleBiometrics(bool enabled) async {
    if (enabled) {
      await EncryptedSecureStorage.setBiometricsEnabled(
          enabled, _masterPassword);
    } else {
      await EncryptedSecureStorage.setBiometricsEnabled(enabled);
    }
    useBiometrics.value = enabled;
  }
}
