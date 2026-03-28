import 'package:flutter/material.dart';
import 'package:logo_n_spinner/logo_n_spinner.dart';

class Spinner extends StatelessWidget {
  const Spinner({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: LogoandSpinner(
        imageAssets: 'assets/logo.png',
        // arcColor: Colors.blue,
        // spinSpeed: Duration(milliseconds: 500),
      ),
    );
  }
}