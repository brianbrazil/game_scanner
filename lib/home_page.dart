import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:focus_on_it/focus_on_it.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'bgg_page.dart';
import 'spinner.dart';
import 'settings.dart';
import 'title_selection_dialog.dart';
import 'game_info.dart';

class HomePage extends StatelessWidget {
  final MobileScannerController scannerController = MobileScannerController(
    autoStart: true,
  );

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FocusOnIt(
      onFocus: () {
        scannerController.start();
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Scan a Barcode")),
        body: body(context),
      ),
    );
  }

  Widget body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: MobileScanner(
                controller: scannerController,
                onDetect: (result) {
                  scannerController.stop();
                  if (result.barcodes.isNotEmpty) {
                    final rawValue = result.barcodes.first.rawValue;
                    context.read<GameUPCModel>().fetchData(rawValue);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) {
                        return Consumer<GameUPCModel>(
                          builder: (context, model, _) {
                            if (model.isLoading) {
                              return Spinner();
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pop(dialogContext);

                                if (model.games.length == 1) {
                                  BggPage(
                                      gameInfo: model.games[0],
                                  ).open(context);
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => TitleSelectionDialog(
                                      games: model.games,
                                      barcode: rawValue!,
                                    ),
                                  ).then((_) {
                                    scannerController.start();
                                  });
                                }
                              });
                              return Spinner();
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(
                    icon: borderedIcon(
                      Icons.flashlight_on,
                      color: Colors.blueGrey,
                    ),
                    iconSize: 65,
                    onPressed: () {
                      scannerController.toggleTorch();
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: borderedIcon(Icons.settings, color: Colors.blueGrey),
                    iconSize: 65,
                    onPressed: () {
                      scannerController.stop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Icon borderedIcon(name, {Color color = Colors.black}) {
  return Icon(
    name,
    shadows: [
      Shadow(offset: Offset(-1.5, -1.5), color: color),
      Shadow(offset: Offset(1.5, -1.5), color: color),
      Shadow(offset: Offset(1.5, 1.5), color: color),
      Shadow(offset: Offset(-1.5, 1.5), color: color),
    ],
  );
}

class GameUPCModel with ChangeNotifier {
  String text = '';
  List<GameInfo> games = [];
  bool isLoading = true;
  bool verified = false;
  String barcode = '';
  final gameUpcApiKey = dotenv.env['GAME_UPC_API_KEY'];
  final gameUpcEnv = dotenv.env['GAME_UPC_ENV'];

  Future<void> fetchData(String? barcode) async {
    try {
      this.barcode = barcode!;
      isLoading = true;
      var response = await http.get(
        Uri.parse('https://api.gameupc.com/$gameUpcEnv/upc/$barcode'),
        headers: {"x-api-key": gameUpcApiKey!},
      );
      var json = jsonDecode(response.body);

      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(json);
      debugPrint('API Response:\n$prettyJson');

      games = GameInfo.fromGameUpc(json);
      games.sort(
            (a, b) => (b.confidence).compareTo(a.confidence),
      );
      text = games.length.toString();
    } catch (e) {
      text = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
