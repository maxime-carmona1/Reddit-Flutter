import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:redditech/constants/app_path.dart';
import 'package:redditech/constants/app_theme.dart';
import 'package:redditech/services/api/authentication_api.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Banner(),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Text(
                  'eplore-without-limits'.i18n(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 30),
                const LoginButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Banner extends StatelessWidget {
  const Banner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: AppTheme.gradientTop,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(130),
                bottomRight: Radius.circular(130),
              ),
              boxShadow: const [AppTheme.boxShadow]),
        ),
        Positioned(
          top: 180,
          left: MediaQuery.of(context).size.width / 2 - 110,
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/reddit_app.png'),
              ),
              boxShadow: [
                AppTheme.boxShadow,
              ],
            ),
          ),
        )
      ],
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await AuthenticationAPI().authentication();
              Modular.to.navigate(AppPath.homeScreenPath);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(220, 60),
              backgroundColor: AppTheme.primary.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.reddit, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "continue-with-reddit".i18n(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : const CircularProgressIndicator(
            color: AppTheme.primary,
          );
  }
}
