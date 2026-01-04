import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'web_page.dart';
import 'spinner.dart';
import 'settings.dart';
import 'bgg_cookies.dart';

class HomePage extends StatelessWidget {
  final BggCookies bggCookies = BggCookies();
  final MobileScannerController scannerController = MobileScannerController(
    autoStart: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Scan a Barcode")
      ),
      body: body(context),
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
                                openWebPage(context, model.games[0],
                                    model.verified);
                              } else if (model.games.length > 1) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      title_selection_dialog(
                                          scannerController),
                                );
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
                    icon: borderedIcon(Icons.flashlight_on, color: Colors.blueGrey),
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
                        MaterialPageRoute(
                          builder: (context) => Settings(),
                        ),
                      ).then((_) {
                        scannerController.start();
                      });
                    },
                  ),
                ]
            ),
          )
        ],
        ),
      ),
    );
  }

  AlertDialog title_selection_dialog(MobileScannerController scannerController) {
    return AlertDialog(
        content: Consumer<GameUPCModel>(
            builder: (context, model, _) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...model.games
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final game = entry.value;
                      final isFirstGame = index == 0;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            openWebPage(context, game, model.verified);
                          },
                          child: Center(
                              child: Text(
                                  game['name'],
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontSize: isFirstGame ? 22 : 14,
                                  )
                              )
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          scannerController.start();
                        },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.red, width: 2),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              );
        }
      )
    );
  }

  void openWebPage(BuildContext context, game, verified) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebPage(
            bgg_info: game,
            verified: verified
        ),
      ),
    ).then((_) {
      scannerController.start();
    });
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
  List<dynamic> games = [];
  bool isLoading = true;
  bool verified = false;
  final gameUpcApiKey = dotenv.env['GAME_UPC_API_KEY'];
  final gameUpcEnv = dotenv.env['GAME_UPC_ENV'];

  Future<void> fetchData(String? barcode) async {
    try {
      isLoading = true;
      var response = await http.get(
        Uri.parse('https://api.gameupc.com/$gameUpcEnv/upc/$barcode'),
        headers: {"x-api-key": gameUpcApiKey!},
      );
      var json = jsonDecode(response.body);
      verified = json['bgg_info_status'] == 'verified';
      games = json['bgg_info'] ?? [];
      games.sort((a, b) =>
          (b['confidence'] ?? 0).compareTo(a['confidence'] ?? 0));
      text = games.length.toString();
    } catch (e) {
      text = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
