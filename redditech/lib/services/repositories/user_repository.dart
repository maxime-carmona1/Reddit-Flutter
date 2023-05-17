import 'dart:async';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  late String token;

  UserRepository();

  // Token
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token').toString();
  }

  Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> setToken(String token) async {
    this.token = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    log('Token set to $token');
  }

  // Username
  Future<void> setUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
  }

  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    return username;
  }
}
