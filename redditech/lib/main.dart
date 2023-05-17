import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:redditech/constants/app_path.dart';
import 'package:redditech/main_module.dart';

void main() {
  Modular.setInitialRoute(AppPath.homeScreenPath);

  runApp(ModularApp(
    module: AppModule(),
    child: const AppWidget(),
  ));
}
