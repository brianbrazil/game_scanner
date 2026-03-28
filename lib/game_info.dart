import 'dart:convert';

class GameInfo {
  const GameInfo({
    required this.barcode,
    required this.bgg_id,
    required this.name,
    required this.published,
    required this.verified,
    required this.confidence,
  });

  final String barcode;
  final int bgg_id;
  final String name;
  final int published;
  final bool verified;
  final int confidence;

  String get bgg_url {
    return 'https://boardgamegeek.com/boardgame/$bgg_id';
  }

  String get upc_update_url {
    return 'https://api.gameupc.com/v1/upc/$barcode/bgg_id/$bgg_id';
  }

  static List<GameInfo> fromGameUpc(dynamic json) {
    json = json is String ? jsonDecode(json) : json;
    final barcode = json['upc'];
    final verified = json['bgg_info_status'] == 'verified';
    final bggInfo = json['bgg_info'] ?? [];

    return bggInfo.map<GameInfo>((game) {
      return GameInfo(
        barcode: barcode,
        bgg_id: int.parse(game['id'].toString()),
        name: game['name'],
        published: int.parse(game['published'].toString()),
        verified: verified,
        confidence: int.parse(game['confidence'].toString()),
      );
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'bgg_id': bgg_id,
      'name': name,
      'published': published,
      'verified': verified,
      'confidence': confidence,
    };
  }
}
