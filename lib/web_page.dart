import 'dart:convert';
import 'dart:typed_data';
import 'package:bgg_api/bgg_api.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
import 'spinner.dart';


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
          if (!verified)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Is this correct?'),
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
              },
              child: Text('Is this correct?'),
            ),

          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add action
            },
          ),

          PopupMenuButton<String>(
            icon: Icon(Icons.menu_rounded),
            onSelected: (String value) {
              // Handle menu item selection
              if (value == 'verify') {
                // TODO: Implement verify action
              } else if (value == 'add_to_collection') {
                // TODO: Implement add to collection action
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'verify',
                child: Text('Verify'),
              ),
              const PopupMenuItem<String>(
                value: 'add_to_collection',
                child: Text('+ Add to Collection'),
              ),
            ],
          ),
        ],
      ),
      body: body(context),
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