import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';

class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  _MedicalHistoryPageState createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  String? selectedStage;
  final TextEditingController diagnosisController = TextEditingController();
  List<String> selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primaryBlue : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Medical History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Diagnosis", "Enter diagnosis details", diagnosisController, isDarkMode),
                    const SizedBox(height: 15),
                    _buildStageSelector(isDarkMode),
                    const SizedBox(height: 15),
                    _buildFilePicker(isDarkMode),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(isDarkMode), // Bouton en bas de l'écran
        ],
      ),
    );
  }

  // 🟢 **En-tête du profil avec l'image et le texte**
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: AppColors.primaryBlue,
      child: const Column(
        children: [
          SizedBox(height: 10),
         
        ],
      ),
    );
  }

  // 🟡 **Champs de texte stylisés**
  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🔵 **Sélecteur de Stage**
  Widget _buildStageSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStageButton("SEP-RR", isDarkMode),
            const SizedBox(width: 10),
            _buildStageButton("SEP-PS", isDarkMode),
            const SizedBox(width: 10),
            _buildStageButton("SEP-PP", isDarkMode),
            const SizedBox(width: 10),
            _buildStageButton("SEP-PR", isDarkMode),
          ],
        ),
      ],
    );
  }

  // 🆕 **Bouton pour sélectionner un Stage**
  Widget _buildStageButton(String stage, bool isDarkMode) {
    bool isSelected = selectedStage == stage;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStage = stage;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : (isDarkMode ? Colors.grey[800] : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey),
          ),
          child: Center(
            child: Text(
              stage,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 📂 **Sélection de fichiers pour les rapports médicaux**
  Widget _buildFilePicker(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reports",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (result != null) {
              setState(() {
                selectedFiles.add(result.files.single.name);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  selectedFiles.isEmpty ? "Select File" : selectedFiles.join(", "),
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔵 **Bouton en bas de l'écran**
  Widget _buildBottomButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Edit",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
