import 'package:flutter/material.dart';

import 'setup_complete_page.dart';

class SetupCaregiverPage extends StatefulWidget {
  const SetupCaregiverPage({super.key});

  @override
  _SetupCaregiverPageState createState() => _SetupCaregiverPageState();
}

class _SetupCaregiverPageState extends State<SetupCaregiverPage> {
  final TextEditingController caregiverNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              "Let’s setup your account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text("A few steps ahead to go.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 15),
            const Text("Primary Caregiver Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 15),
            _buildTextField("Primary caregiver name", "Enter caregiver name", caregiverNameController, isDarkMode),
            const SizedBox(height: 15),
            _buildTextField("Email", "Enter email here", emailController, isDarkMode),
            const SizedBox(height: 15),
            _buildTextField("Phone", "Enter phone number here", phoneController, isDarkMode),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetupCompletePage()),
                );
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(100, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Next", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildProgressBar(),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 10),
            
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: label == "Phone" ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: 0.75, // Progression mise à jour
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
