import 'package:flutter/material.dart' hide Page;
import 'package:get/get.dart';
import 'package:life_line/page/controller.dart';
import 'package:life_line/page/page.dart';
import 'package:life_line/page/password.page.dart';

void main() {
  Get.put(MainPageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const PasswordPage(),
    );
  }
}
