import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'settings.dart';

class BggCookies {
  final Map<String,String> cookies = {};
  final _cookieManager = WebViewCookieManager();
  bool _locked = false;

  BggCookies();
  
  Future<String?> _getBggUsername() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: Settings.bggUsernameKey);
  }

  Future<String?> _getBggPassword() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: Settings.bggPasswordKey);
  }

  Future<String?> _bggCredentials() async {
    final username = await _getBggUsername();
    final password = await _getBggPassword();
    if (username == null || password == null) {
      return null;
    }
    return jsonEncode({
      "credentials": {
        "username": username,
        "password": password
      }
    });
  }
  
  bool loggedIn() {
    return cookies.keys.contains('bggusername')
        && cookies.keys.contains('bggpassword')
        && cookies.keys.contains('SessionID');
  }
  
  Future<void> login() async {
    if (loggedIn()) { return; }
    if (await _bggCredentials() == null) { return; }
    if (_locked) { return;}
    _locked = true;
    final response = await http.post(
      Uri.parse('https://boardgamegeek.com/login/api/v1'),
      headers: {"Content-Type": "application/json"},
      body: await _bggCredentials(),
    );

    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Cookies in set-cookie can be complex; we split by ';' and then handle the key=value pairs.
      // Note: A robust solution would use a cookie parsing library, but for these specific keys:
      final cookies = rawCookie.split(','); // Headers are often comma-separated if combined

      for (var cookie in cookies) {
        final parts = cookie.split(';')[0].split('=');
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final value = parts[1].trim();

          await _cookieManager.setCookie(
            WebViewCookie(
              name: name,
              value: value,
              domain: 'boardgamegeek.com',
              path: '/',
            ),
          );
          this.cookies[name] = value;
        }
      }
      _locked = false;
    }
  }
}