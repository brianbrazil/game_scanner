import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  static const prefsUsernameKey = 'bgg_username';
  static const securePasswordKey = 'bgg_password';
  static const prefsGameUpcUserId = 'game_upc_user_id';

  Future<Map<String, String?>> _loadValues() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = const FlutterSecureStorage();
    final username = prefs.getString(prefsUsernameKey);
    final password = await storage.read(key: securePasswordKey);
    final gameUpcUserId = prefs.getString(prefsGameUpcUserId);
    return {
      'username': username,
      'password': password,
      'gameUpcUserId': gameUpcUserId,
    };
  }

  Future<void> _saveUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsUsernameKey, value);
  }

  Future<void> _savePassword(String value) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: securePasswordKey, value: value);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>> (
      future: _loadValues(),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final bggUsername = snapshot.data?['username'] ?? '';
        final bggPassword = snapshot.data?['password'] ?? '';
        final gameUpcUuid = snapshot.data?['gameUpcUserId'] ?? '';

        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: bggUsername,
                  decoration: const InputDecoration(
                    labelText: 'BGG Username',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (value) {
                    // Fire and forget is fine here; UI stays responsive.
                    _saveUsername(value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: bggPassword,
                  decoration: const InputDecoration(
                    labelText: 'BGG Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (value) {
                    _savePassword(value);
                  },
                ),
                SizedBox(height: 50),
                TextFormField(
                  readOnly: true,
                  initialValue: gameUpcUuid,
                  decoration: const InputDecoration(
                    labelText: 'GameUPC User ID',
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
