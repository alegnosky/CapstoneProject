import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/Screens/HomeScreen.dart';
import 'package:vpn_capstone/Screens/PasswordManagementScreen.dart';
import 'package:vpn_capstone/passwordServices/encryptedPasswordStorage.dart';
import 'package:vpn_capstone/Controllers/passwordController.dart';

class PasswordAuthScreen extends StatefulWidget {
  @override
  _PasswordAuthScreenState createState() => _PasswordAuthScreenState();
}

class _PasswordAuthScreenState extends State<PasswordAuthScreen> {
  final TextEditingController _passwordInputController =
      TextEditingController();
  final _passwordController = Get.find<PasswordController>();
  bool _isLoading = false;
  bool _isSetup = false;
  bool _obscureText = true;
  String _errorMessage = '';
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final hasPassword = await EncryptedSecureStorage.isMasterPasswordSet();
    final canUseBio = await EncryptedSecureStorage.canUseBiometrics() &&
        await EncryptedSecureStorage.isBiometricsEnabled();

    setState(() {
      _isSetup = !hasPassword;
      _canUseBiometrics = canUseBio;
      _isLoading = false;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    bool didAuthenticate = false;
    try {
      didAuthenticate =
          await EncryptedSecureStorage.authenticateWithBiometrics();
    } catch (e) {
      print("Error Authenticating: $e");
      setState(() {
        _errorMessage = 'Biometric error, Use password instead';
        _isLoading = false;
      });
      return;
    }
    if (didAuthenticate && mounted) {
      final masterPassword =
          await EncryptedSecureStorage.getMasterPasswordForBiometrics();
      if (masterPassword != null && masterPassword.isNotEmpty) {
        _passwordController.setMasterPassword(masterPassword);
        _passwordController.setAuthenticated(true);
        Get.off(() => PasswordManagementScreen());
      } else {
        await _promptForPassword();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() {
        _errorMessage = 'Biometric Authentication Failed';
        _isLoading = false;
      });
    }
  }

  Future<void> _promptForPassword() async {
    final TextEditingController dialogPasswordController =
        TextEditingController();

    bool obscureDialogText = true;
    String? dialogError;

    String? enteredPassword = await Get.dialog<String>(
      StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text("Unlock Session"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Enter your master password to decrypt your data for this session."),
              SizedBox(height: 16),
              TextField(
                controller: dialogPasswordController,
                obscureText: obscureDialogText,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Master Password",
                  border: OutlineInputBorder(),
                  errorText: dialogError,
                  suffixIcon: IconButton(
                    icon: Icon(obscureDialogText
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setStateDialog(() {
                        obscureDialogText = !obscureDialogText;
                      });
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _verifyPassword(dialogPasswordController.text.trim());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  dialogPasswordController.dispose();
                  Get.back(result: null);
                },
                child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final password = dialogPasswordController.text.trim();
                if (password.isEmpty) {
                  setStateDialog(() {
                    dialogError = "Password cannot be empty";
                  });
                  return;
                }

                Get.back(result: password);
              },
              child: Text("Unlock"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );

    if (enteredPassword != null) {
      await _verifyPassword(enteredPassword);
    } else {
      setState(() {
        _errorMessage = 'Password entry cancelled.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPassword(String password) async {
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final isValid = await EncryptedSecureStorage.verifyMasterPassword(password);

    if (isValid && mounted) {
      _passwordController.setMasterPassword(password);
      _passwordController.setAuthenticated(true);
      Get.off(() => PasswordManagementScreen());
    } else if (mounted) {
      setState(() {
        _errorMessage = 'Incorrect master password entered after biometrics.';
        _isLoading = false;
      });
    }
  }

  Future<void> _processPassword() async {
    final password = _passwordInputController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password is empty';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isSetup) {
        final success =
            await EncryptedSecureStorage.setupMasterPassword(password);
        if (success) {
          _passwordController.setMasterPassword(password);
          _passwordController.setAuthenticated(true);
          Get.off(() => PasswordManagementScreen());
        } else {
          setState(() {
            _errorMessage = 'Failed to set password';
          });
        }
      } else {
        final isValid =
            await EncryptedSecureStorage.verifyMasterPassword(password);
        if (isValid) {
          _passwordController.setMasterPassword(password);
          _passwordController.setAuthenticated(true);
          Get.off(() => PasswordManagementScreen());
        } else {
          setState(() {
            _errorMessage = 'Incorrect password';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: Text(
              _isSetup ? "Create Master Password" : "Enter Master Password"),
          automaticallyImplyLeading: !_isSetup,
          leading: _isSetup
              ? null
              : IconButton(
                  onPressed: () {
                    Get.offAll(() => HomeScreen());
                  },
                  icon: Icon(Icons.arrow_back))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.security_rounded,
                      size: 80,
                      color: Colors.blueGrey[600],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isSetup
                          ? "Set a strong master password for your vault."
                          : "Unlock your password vault.",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _passwordInputController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        labelText: _isSetup
                            ? "New Master Password"
                            : "Master Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => _processPassword(),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _processPassword,
                      child: Text(_isSetup ? "Create Password" : "Unlock"),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                    if (!_isSetup && _canUseBiometrics)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: OutlinedButton.icon(
                            icon:
                                Icon(Icons.fingerprint, color: Colors.blueGrey),
                            label: Text("Use Biometrics",
                                style: TextStyle(color: Colors.blueGrey[700])),
                            onPressed: _authenticateWithBiometrics,
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                side:
                                    BorderSide(color: Colors.blueGrey.shade300),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)))),
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
