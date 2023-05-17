import 'dart:developer';

import 'package:draw/draw.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:redditech/constants/reddit_info.dart';
import 'package:redditech/services/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationAPI {
  late Reddit reddit;
  late Uri authUrl;
  late String result;
  late String code;
  late Redditor? currentUser;
  late SharedPreferences prefs;

  authentication() async {
    await initInstance();
    setAuthUrl();
    await launchUrl();
    code = await setCode();
    await setCurrentUser();
    await setToken();
  }

  initInstance() async {
    reddit = Reddit.createInstalledFlowInstance(
      clientId: RedditInfo.clientId,
      userAgent: RedditInfo.userAgent,
      redirectUri: Uri.parse(RedditInfo.redirectUri),
    );
  }

  setAuthUrl() {
    authUrl = reddit.auth.url(['*'], 'ReddiFlutter');
  }

  launchUrl() async {
    result = await FlutterWebAuth.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'foobar',
    );
  }

  Future<String> setCode() async {
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw Exception('Authentication code not found');
    }
    await reddit.auth.authorize(code);
    return code;
  }

  setCurrentUser() async {
    currentUser = await reddit.user.me();
    Modular.get<UserRepository>().setUsername(currentUser!.displayName);
    log("Logged in as ${currentUser?.displayName}");
  }

  setToken() async {
    await Modular.get<UserRepository>()
        .setToken(reddit.auth.credentials.accessToken);
  }
}
