import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await registerServices();

  runApp(const MyApp());
}

Future<void> registerServices() async {
  // get and init local storage
  final localStorageService = Get.put(LocalStorageService());
  await localStorageService.init();

  Get.lazyPut(
    () => LocalStorageController(
      localStorageService: localStorageService,
    ),
  );
}
