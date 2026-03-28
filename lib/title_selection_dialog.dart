import 'package:flutter/material.dart';
import 'bgg_page.dart';
import 'game_info.dart';

class TitleSelectionDialog extends StatelessWidget {
  const TitleSelectionDialog({
    super.key,
    required this.games,
  });

  final List<GameInfo> games;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...titleButtons(context),
            cancelButton(context),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> titleButtons(BuildContext context) {
    return games.map((game) {
      final isFirstGame = games.indexOf(game) == 0;
      return titleButton(context, game, isFirstGame);
    });
  }

  SizedBox titleButton(BuildContext context, GameInfo game, bool isFirstGame) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          BggPage(
            gameInfo: game,
          ).open(context);
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
