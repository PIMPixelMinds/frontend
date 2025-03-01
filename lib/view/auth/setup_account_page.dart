/*import 'package:flutter/material.dart';
import 'package:pim/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'setup_contact_page.dart';

class SetupAccountPage extends StatefulWidget {
  const SetupAccountPage({super.key});

  @override
  _SetupAccountPageState createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedGender;
  final List<String> genderOptions = ["Male", "Female", "Other"];

  // Format date to ISO 8601 (e.g., "2023-10-05")
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.radio_button_checked,
                size: 60, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              "Let’s setup your account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text("A few steps ahead to go.",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 15),
            const Text("Personal Details",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey)),
            const SizedBox(height: 15),
            _buildTextField("Full Name", "Enter your name", fullNameController,
                false, isDarkMode),
            const SizedBox(height: 15),
            _buildDropdownField("Gender", isDarkMode),
            const SizedBox(height: 15),
            _buildDatePickerField("Date of Birth", isDarkMode),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Validate inputs
                if (fullNameController.text.isEmpty ||
                    selectedGender == null ||
                    dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }

                // Call the updateProfile method
                await authViewModel.updateProfile(
                  context: context,
                  newName: fullNameController.text.trim(),
                  newEmail: "", // Add email field if needed
                  newBirthday: dateController.text.trim(),
                  newGender: selectedGender ?? "Male",
                );

                // Navigate to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetupContactPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Next",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, bool isPassword, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              hint: const Text("Select your Gender"),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
              items: genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "mm/dd/yyyy",
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              /*onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                setState(() {
                  dateController.text = _formatDate(pickedDate); // Format the date
                });
                }*/
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    dateController.text = _formatDate(pickedDate);
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
*/