import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'spinner.dart';
import 'bgg_cookies.dart';
import 'settings.dart';


class VerifiedModel extends ChangeNotifier {
  bool verified;

  VerifiedModel(this.verified);

  void setVerified(bool value) {
    verified = value;
    notifyListeners();
  }
}

class WebPage extends StatelessWidget {
  final Map<String, dynamic> bgg_info;
  final bool verified;

  WebPage({
    super.key,
    required this.bgg_info,
    required this.verified
  });

  @override
  Widget build(BuildContext context) {
    bgg_info.forEach((key, value) {
      print('$key -> $value');
    });
    return ChangeNotifierProvider(
      create: (_) => VerifiedModel(verified),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Consumer<VerifiedModel>(
              builder: (context, model, _) {
                return PopupMenuButton<String>(
                  icon: Icon(Icons.menu_rounded),
                  onSelected: (String value) {
                    if (value == 'verify_barcode') {
                      showConfirmVerificationDialog(context);
                    } else
                    if (value == 'reset_barcode') {
                      showResetVerificationDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final verifyMenuItem = model.verified
                        ? const PopupMenuItem<String>(
                            value: 'reset_barcode',
                            child: Text('Reset Barcode'),
                          )
                        : const PopupMenuItem<String>(
                            value: 'verify_barcode',
                            child: Text('Verify Barcode'),
                          );
                    return <PopupMenuEntry<String>>[verifyMenuItem];
                  },
                );
              },
            ),
          ],
        ),
        body: FutureBuilder(
          future: BggCookies().login(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Spinner();
            }
            return body(context);
          },
        ),
      ),
    );
  }

  void showConfirmVerificationDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final verifiedModel = context.read<VerifiedModel>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(
              'Do you want to verify this barcode matches this game?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                var response = await http.post(
                    Uri.parse(bgg_info['update_url']),
                    headers: {"x-api-key": dotenv.env['GAME_UPC_API_KEY']!},
                    body: jsonEncode({
                      "user_id": prefs.getString(Settings.prefsGameUpcUserId)!
                    })
                );
                print(response.body);
                verifiedModel.setVerified(true);
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void showResetVerificationDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final verifiedModel = context.read<VerifiedModel>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(
              'Do you want to verify this barcode does not match this game?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                var response = await http.delete(
                    Uri.parse(bgg_info['update_url']),
                    headers: {"x-api-key": dotenv.env['GAME_UPC_API_KEY']!},
                    body: jsonEncode({
                      "user_id": prefs.getString(Settings.prefsGameUpcUserId)!
                    })
                );
                print(response.body);
                verifiedModel.setVerified(false);
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Widget body(BuildContext context) {
    var params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    WebViewController controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            showDialog(
              context: context,
              builder: (context) {
                return Spinner();
              }
            );
          },
          onPageFinished: (String url) {
            Navigator.pop(context);
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {
            print('HTTP Error Status Code: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(bgg_info['page_url']));

    return Center(
      child: WebViewWidget(controller: controller),
    );
  }
}