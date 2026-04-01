import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BggSearch {
  static Future<dynamic> search(String query) async {
    final uri = Uri.parse('https://boardgamegeek.com/search/boardgame?q=$query&nosession=1&showcount=50&singular=1');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    return jsonDecode(response.body);
  }
}


