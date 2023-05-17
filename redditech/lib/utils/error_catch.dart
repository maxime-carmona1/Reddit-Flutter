import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:redditech/constants/app_path.dart';
import 'package:redditech/constants/app_theme.dart';
import 'package:redditech/services/repositories/user_repository.dart';

abstract class ErrorCatch {
  static Future<void> catchError(
      AsyncSnapshot snapshot, BuildContext context) async {
    if (snapshot.error.toString().contains('Unauthorized')) {
      await Modular.get<UserRepository>()
          .deleteToken()
          .then((value) => Modular.to.navigate(AppPath.loginScreenPath));
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snapshot.error.toString()),
              duration: const Duration(seconds: 15),
              backgroundColor: AppTheme.secondary,
            ),
          );
        },
      );
    }
  }
}
