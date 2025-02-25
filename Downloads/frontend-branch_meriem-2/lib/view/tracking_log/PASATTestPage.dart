import 'package:flutter/material.dart';

class PASATTestPage extends StatelessWidget {
  const PASATTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PASAT Test')),
      body: Center(child: Text('Paced Auditory Serial Addition Test (PASAT)')),
    );
  }
}
