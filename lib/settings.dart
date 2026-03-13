import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  static const bggUsernameKey = 'bgg_username';
  static const bggPasswordKey = 'bgg_password';
  static const gameUpcUserIdKey = 'game_upc_user_id';

  static const storage = FlutterSecureStorage();

  Future<Map<String, String?>> _loadValues() async {
    final username = await storage.read(key: bggUsernameKey);
    final password = await storage.read(key: bggPasswordKey);
    final gameUpcUserId = await storage.read(key: gameUpcUserIdKey);
    return {
      'username': username,
      'password': password,
      'gameUpcUserId': gameUpcUserId,
    };
  }

  Future<void> _saveUsername(String value) async {
    await storage.write(key: bggUsernameKey, value: value);
  }

  Future<void> _savePassword(String value) async {
    await storage.write(key: bggPasswordKey, value: value);
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
