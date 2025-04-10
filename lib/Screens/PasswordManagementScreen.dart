import 'package:flutter/material.dart';
import 'package:vpn_capstone/passwordServices/passwordGenerator.dart';
import 'package:vpn_capstone/passwordServices/passwordStorage.dart';
import 'package:flutter/services.dart';

class PasswordManagementScreen extends StatefulWidget {
  @override
  _PasswordManagementScreenState createState() =>
      _PasswordManagementScreenState();
}

class _PasswordManagementScreenState extends State<PasswordManagementScreen> {
  final TextEditingController _identifierController = TextEditingController();
  String _generatedPassword = "";
  Map<String, String> _savedPasswords = {};

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = PasswordGenerator.generate();
    });
  }

  Future<void> _savePassword() async {
    String identifier = _identifierController.text.trim();
    if (identifier.isEmpty || _generatedPassword.isEmpty) return;

    await SecureStorage.savePassword(identifier, _generatedPassword);
    _identifierController.clear();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    Map<String, String> passwords = await SecureStorage.getPasswords();
    setState(() {
      _savedPasswords = passwords;
    });
  }

  Future<void> _deletePassword(String identifier) async {
    await SecureStorage.deletePassword(identifier);
    _loadPasswords();
  }

  void _clipBoardCopy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied to Clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Manager"),
      backgroundColor: Colors.blueGrey),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _identifierController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Website or Application Name",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: TextEditingController(text: _generatedPassword),
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Generated Password",
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _generatePassword,
                  child: Text("Generate Password"),
                ),
                ElevatedButton(
                  onPressed: _savePassword,
                  child: Text("Save Password"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Saved Passwords:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: _savedPasswords.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => _clipBoardCopy(entry.value),
                            icon: Icon(Icons.copy, color: Colors.blue)),
                        IconButton(onPressed: ()=> _deletePassword(entry.key),
                            icon: Icon(Icons.delete, color: Colors.red))
                    ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
