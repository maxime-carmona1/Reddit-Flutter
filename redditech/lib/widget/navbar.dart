import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:redditech/constants/app_path.dart';
import 'package:redditech/constants/app_theme.dart';
import 'package:redditech/services/repositories/user_repository.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key, required Widget body})
      : _body = body,
        super(key: key);

  final Widget _body;
  final int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body,
      bottomNavigationBar: ConvexAppBar(
        gradient: AppTheme.gradientSide,
        backgroundColor: AppTheme.primary,
        activeColor: Colors.white,
        items: [
          TabItem(icon: Icons.person, title: 'profile'.i18n()),
          TabItem(icon: Icons.home, title: 'home'.i18n()),
          TabItem(icon: Icons.logout, title: 'logout'.i18n()),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int index) async {
          switch (index) {
            case 0:
              Modular.to.navigate(AppPath.profileScreenPath);
              break;
            case 1:
              Modular.to.navigate(AppPath.homeScreenPath);
              break;
            case 2:
              confirmLogout(context);
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}

confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: SizedBox(
          width: 300,
          height: 200,
          child: AlertDialog(
            title: Text(
              'confirm-logout'.i18n(),
              textAlign: TextAlign.center,
            ),
            titlePadding: const EdgeInsets.only(top: 18),
            actionsAlignment: MainAxisAlignment.center,
            insetPadding: const EdgeInsets.all(25),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('no'.i18n(),
                    style: const TextStyle(color: AppTheme.secondary)),
              ),
              TextButton(
                onPressed: () async {
                  await Modular.get<UserRepository>().deleteToken();
                  Modular.to.navigate(AppPath.loginScreenPath);
                },
                child: Text(
                  'yes'.i18n(),
                  style: const TextStyle(color: AppTheme.secondary),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
