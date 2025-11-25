import 'package:admin_panel/admin_auth/login_page.dart';
import 'package:admin_panel/splash_screen.dart';
import 'package:admin_panel/utils/provider_list/provider_list.dart';
import 'package:admin_panel/utils/routs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(MultiProvider(
      providers: ProviderList.providers,
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const AdminLoginScreen() : const SplashScreen(),
        getPages: Routs.getPages,
      ),
    );
  }
}
