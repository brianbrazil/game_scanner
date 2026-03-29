import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bgg_page.dart';
import 'game_info.dart';

class TitleSelectionDialog extends StatelessWidget {
  const TitleSelectionDialog({super.key, required this.games});

  final List<GameInfo> games;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DialogGamesModel(games),
      child: Consumer<DialogGamesModel>(
        builder: (context, model, _) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...titleButtons(context, model.games),
                  cancelButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Iterable<Widget> titleButtons(BuildContext context, List<GameInfo> games) {
    return games.asMap().entries.map((entry) {
      final index = entry.key;
      final game = entry.value;
      return titleButton(context, game, index == 0);
    });
  }

  SizedBox titleButton(BuildContext context, GameInfo game, bool isFirstGame) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          BggPage(gameInfo: game).open(context);
        },
        child: Center(
          child: Text(
            '${game.name} (${game.published})',
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: isFirstGame ? 22 : 14),
          ),
        ),
      ),
    );
  }

  SizedBox cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          side: BorderSide(color: Colors.red, width: 2),
        ),
        child: Text('Cancel'),
      ),
    );
  }
}

class DialogGamesModel extends ChangeNotifier {
  DialogGamesModel(List<GameInfo> games) : _games = List<GameInfo>.from(games);

  final List<GameInfo> _games;

  List<GameInfo> get games => List.unmodifiable(_games);

  void setGames(List<GameInfo> games) {
    _games
      ..clear()
      ..addAll(games);
    notifyListeners();
  }

  void addGame(GameInfo game) {
    _games.add(game);
    notifyListeners();
  }

  void removeGame(GameInfo game) {
    _games.remove(game);
    notifyListeners();
  }
}
