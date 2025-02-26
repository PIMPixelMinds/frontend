import 'package:flutter/material.dart';

class SDMTTestPage extends StatelessWidget {
  const SDMTTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDMT Test')),
      body: Center(child: Text('Symbol Digit Modalities Test (SDMT)')),
    );
  }
}
