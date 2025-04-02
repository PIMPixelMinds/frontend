import 'package:flutter/material.dart';
import 'setup_account_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text("Setup Account"),
              leading: const Icon(Icons.account_circle),
              /*onTap: () {
                Navigator.push(
                  context,
                  //MaterialPageRoute(builder: (context) => SetupAccountPage()),
                );
              },*/
            ),
          ],
        ),
      ),
    );
  }
}
