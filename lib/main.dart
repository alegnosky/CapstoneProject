import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_capstone/Controllers/HomeController.dart';
import 'package:vpn_capstone/Controllers/passwordController.dart';
import 'package:vpn_capstone/Screens/HomeScreen.dart';
import 'package:vpn_capstone/appPreferences/appPreferences.dart';


late Size screenSize;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.initHive();
  Get.put(HomeController());
  Get.put(PasswordController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppPreferences.darkModeNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Capstone - Android Security Suite',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 3),
      ),
      themeMode:
      AppPreferences.darkModeNotifier.value ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 3),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }

  @override
  void dispose() {
    AppPreferences.darkModeNotifier.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }
}
