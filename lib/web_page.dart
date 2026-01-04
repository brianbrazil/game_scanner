import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
import 'spinner.dart';
import 'bgg_cookies.dart';


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
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu_rounded),
            onSelected: (String value) {
              if (value == 'verify_barcode') {
                showConfirmVerificationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'verify_barcode',
                child: Text('Verify Barcode'),
              ),
            ],
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
    );
  }

  void showConfirmVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(
              'Do you want to verify this barcode matches this game?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                  headers: {"x-api-key": "test_test_test_test_test"},
                    body: jsonEncode({
                      "user_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
                    })
                );
                print(response.body);
                Navigator.of(context).pop();
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