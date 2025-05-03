import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/Controllers/passwordController.dart';
import 'package:flutter/services.dart';
import 'package:vpn_capstone/passwordServices/passwordAuthentication.dart';

class PasswordManagementScreen extends StatefulWidget {
  @override
  _PasswordManagementScreenState createState() =>
      _PasswordManagementScreenState();
}

class _PasswordManagementScreenState extends State<PasswordManagementScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _passwordStrength = 0.0.obs;
  final _passwordManager = Get.isRegistered<PasswordController>()
      ? Get.find<PasswordController>()
      : Get.put(PasswordController());

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    _passwordManager.generatePassword();
    _passwordController.text = _passwordManager.generatedPassword.value;
    _calculatePasswordStrength(_passwordManager.generatedPassword.value);
  }

  Future<void> _generatePassphrase() async {
    await _passwordManager.generatePassphrase();
    _passwordController.text = _passwordManager.generatedPassword.value;
    _calculatePasswordStrength(_passwordManager.generatedPassword.value);
  }

  void _calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.isNotEmpty) {
      if (password.length >= 8) strength += 0.2;
      if (password.length >= 16) strength += 0.2;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    }
    _passwordStrength.value = strength;
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength < 0.3) return "Weak";
    if (strength < 0.7) return "Medium";
    return "Strong";
  }

  Future<void> _savePassword() async {
    String identifier = _identifierController.text.trim();
    String password = _passwordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Enter both site name and password/passphrase",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final success = await _passwordManager.savePassword(identifier, password);
    if (success) {
      _identifierController.clear();
      _generatePassword();
      Get.snackbar("Success", "Password Saved",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    }
  }

  void _clipBoardCopy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied to Clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Manager"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _passwordManager.setAuthenticated(false);
              Get.offAll(() => PasswordAuthScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Website or App Name",
                prefixIcon: Icon(Icons.web),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Password / Passphrase",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () => _clipBoardCopy(_passwordController.text),
                ),
              ),
              onChanged: _calculatePasswordStrength,
            ),
            SizedBox(height: 8),
            Obx(() => LinearProgressIndicator(
                  value: _passwordStrength.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(_passwordStrength.value)),
                )),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _generatePassword,
                  icon: Icon(Icons.refresh),
                  label: Text("Password"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _generatePassphrase,
                  icon: Icon(Icons.article),
                  label: Text("Passphrase"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _savePassword,
                  icon: Icon(Icons.save),
                  label: Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              "Saved Credentials",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: Obx(() => _passwordManager.savedPasswords.isEmpty
                  ? Center(
                      child: Text(
                        "No saved credentials",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _passwordManager.savedPasswords.length,
                      itemBuilder: (context, index) {
                        final entry = _passwordManager.savedPasswords.entries
                            .elementAt(index);
                        return _buildPasswordItem(entry.key, entry.value);
                      },
                    )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordItem(String identifier, String password) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Text(
            identifier.isNotEmpty ? identifier[0].toUpperCase() : "?",
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(identifier),
        subtitle: Text(
          "●" * (password.length > 10 ? 10 : password.length),
          style: TextStyle(letterSpacing: 2),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.copy, color: Colors.blue),
              onPressed: () => _clipBoardCopy(password),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(identifier),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                      leading: Icon(Icons.fingerprint),
                      title: Text("Enable Biometrics"),
                      trailing: Obx(() => Switch(
                            value: _passwordManager.useBiometrics.value,
                            onChanged: (value) {
                              _passwordManager.toggleBiometrics(value);
                            },
                          ))),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text("Change Master Password"),
                    onTap: _showChangePasswordDialog,
                  )
                ],
              ),
            ));
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    Get.back();
    Get.dialog(
      AlertDialog(
        title: Text("Change Master Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                isDense: true,
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                Get.snackbar("Error", "New passwords don't match",
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              final success = await _passwordManager.changeMasterPassword(
                  currentController.text, newController.text);
              if (success) {
                Get.back();
                Get.snackbar("Success", "Master password changed successfully",
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text("Change"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String identifier) {
    Get.dialog(AlertDialog(
      title: Text("Delete Password"),
      content: Text("Confirm password deletion for $identifier"),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await _passwordManager.deletePassword(identifier);
            Get.back();
            if (success) {
              Get.snackbar("Success", "Password Deleted.",
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text("Delete"),
        )
      ],
    ));
  }
}
