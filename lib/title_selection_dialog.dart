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
            ...games.asMap().entries.map((entry) {
              final index = entry.key;
              final game = entry.value;
              final isFirstGame = index == 0;
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
            }),
            SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
