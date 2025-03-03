import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'setup_caregiver_page.dart';

class SetupMedicalPage extends StatefulWidget {
  const SetupMedicalPage({super.key});

  @override
  _SetupMedicalPageState createState() => _SetupMedicalPageState();
}

class _SetupMedicalPageState extends State<SetupMedicalPage> {
  String? selectedDiagnosis;
  String? selectedStage;
  String? fileName;

  final List<String> diagnosisOptions = ["Alzheimer", "Dementia", "Parkinson", "Other"];
  final List<String> stageOptions = ["Early", "Moderate", "Severe"];

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
            const Text("Medical History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 15),
            _buildDropdownField("Diagnosis", selectedDiagnosis, diagnosisOptions, (value) {
              setState(() {
                selectedDiagnosis = value;
              });
            }, isDarkMode),
            const SizedBox(height: 15),
            _buildDropdownField("Stage", selectedStage, stageOptions, (value) {
              setState(() {
                selectedStage = value;
              });
            }, isDarkMode),
            const SizedBox(height: 15),
            _buildFileUploadSection(),
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
                  MaterialPageRoute(builder: (context) => SetupCaregiverPage()),
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

  Widget _buildDropdownField(String label, String? selectedValue, List<String> options, Function(String?) onChanged, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: const Text("Select"),
              isExpanded: true,
              onChanged: onChanged,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Medical Reports (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        const Text(
          "Max file size is 500kb. Supported file types are .jpg and .pdf.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _pickFile,
          child: const Text("Upload"),
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text("File: $fileName", style: const TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.single.size <= 500000) {
      setState(() {
        fileName = result.files.single.name;
      });
    } else {
      // Afficher une alerte si le fichier est trop grand
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File size must be under 500KB"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: 0.5,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
