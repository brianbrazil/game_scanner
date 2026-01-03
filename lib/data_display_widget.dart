import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class DataDisplayWidget extends StatefulWidget {
  final String barcode;

  const DataDisplayWidget({
    Key? key,
    required this.barcode,
  }) : super(key: key);

  @override
  State<DataDisplayWidget> createState() => _DataDisplayWidgetState();
}

class _DataDisplayWidgetState extends State<DataDisplayWidget> {
  String text = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var response = await http.get(
        Uri.parse('https://api.gameupc.com/test/upc/${widget.barcode}'),
        headers: {"x-api-key": "test_test_test_test_test"},
      );

      if (mounted) {
        setState(() {
          text = response.body;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Text(errorMessage!),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Text(text),
    );
  }
}
