import 'package:flutter/material.dart';
import '../home/home_page.dart';

class SetupCompletePage extends StatelessWidget {
  const SetupCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.radio_button_checked, size: 60, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              "Good to go!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image.asset("assets/success_image.png", height: 200), // Ajouter cette image dans assets
            const SizedBox(height: 20),
            const Text("All done!", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 15),
            const Text(
              "Let’s start our wonderful journey\nwith MSAware.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false, // Supprime tout l'historique de navigation
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const Spacer(),
            _buildProgressBar(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 24),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: 1.0, // Progression complète
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ],
    );
  }
}
