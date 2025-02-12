import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'setup_account_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Données utilisateur
  String fullName = "Son Gokuuuu";
  String gender = "male";
  String birthday = "test";
  String email = "benmabroukyassine399@gmail.com";
  String phoneNumber = "+123 456 7890";
  String address = "123 Saiyan Street, Universe 7";
  String diagnosis = "O+";
  String stage = "None";
  String file = "None";
  String caregiverName = "Chi-Chi";
  String caregiverPhone = "+987 654 3210";
  String caregiverEmail = "test";

  // Vérification et demande de permissions
  Future<bool> _checkPermissions(ImageSource source) async {
    var status = await (source == ImageSource.camera ? Permission.camera.request() : Permission.photos.request());
    return status.isGranted;
  }

  // Sélection d'une image
  Future<void> _pickImage(ImageSource source) async {
    if (!(await _checkPermissions(source))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez accorder les permissions nécessaires")));
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 800, maxHeight: 800);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final localPath = '${appDir.path}/$fileName';
        await pickedFile.saveTo(localPath);
        setState(() {
          _image = File(localPath);
        });
      }
    } catch (e) {
      print("🚨 Erreur lors de la sélection d'image : $e");
    }
  }

  // Affiche le BottomSheet pour modifier une information
  void _showEditBottomSheet(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Modifier $title", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: "Enter new $title",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onSave(controller.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Affiche le menu de sélection d'image
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(leading: const Icon(Icons.photo_library), title: const Text("Galerie"), onTap: () => _pickImage(ImageSource.gallery)),
              ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Caméra"), onTap: () => _pickImage(ImageSource.camera)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color sectionColor = isDarkMode ? Colors.grey[900]! : Colors.blue.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: sectionColor,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? Icon(Icons.camera_alt, color: isDarkMode ? Colors.white : Colors.blue.shade700, size: 40) : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            _buildSection("Personal Information", Icons.person, sectionColor, textColor, [
              _buildInfoTile("Full Name", fullName, textColor, (val) => setState(() => fullName = val)),
              _buildInfoTile("Birthday", birthday, textColor, (val) => setState(() => birthday = val)),
              _buildInfoTile("Gender", gender, textColor, (val) => setState(() => gender = val)),
            ]),
            _buildSection("Contact Details", Icons.phone, sectionColor, textColor, [
              _buildInfoTile("E-mail Address", email, textColor, (val) => setState(() => email = val)),
              _buildInfoTile("Phone Number", phoneNumber, textColor, (val) => setState(() => phoneNumber = val)),
              _buildInfoTile("Address", address, textColor, (val) => setState(() => address = val)),
            ]),
            _buildSection("Medical History", Icons.medical_services, sectionColor, textColor, [
              _buildInfoTile("Diagnosis", diagnosis, textColor, (val) => setState(() => diagnosis = val)),
              _buildInfoTile("Stage", stage, textColor, (val) => setState(() => stage = val)),
              _buildInfoTile("file", file, textColor, (val) => setState(() => file = val)),
            ]),
            _buildSection("Primary Caregiver", Icons.people, sectionColor, textColor, [
              _buildInfoTile("Caregiver Name", caregiverName, textColor, (val) => setState(() => caregiverName = val)),
              _buildInfoTile("Caregiver Phone", caregiverPhone, textColor, (val) => setState(() => caregiverPhone = val)),
              _buildInfoTile("Caregiver Email", caregiverEmail, textColor, (val) => setState(() => caregiverEmail = val)),
            ]),
            _buildSection("Account Settings", Icons.settings, sectionColor, textColor,[
              _buildActionTile(Icons.person, "Edit Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetupAccountPage()),
                );
              },),
              _buildActionTile(Icons.lock, "Change Password", _showChangePasswordDialog),
              _buildActionTile(Icons.logout, "Log-Out", _logout),
            ]),
          ],
        ),
      ),
    );
  }

void _showChangePasswordDialog() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmNewPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Change password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildPasswordField("Current Password", passwordController),
              _buildPasswordField("New Password", newPasswordController),
              _buildPasswordField("Confirm new password", confirmNewPasswordController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Change", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          hintText: label,
        ),
      ),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logout")));
  }

  Widget _buildSection(String title, IconData icon, Color sectionColor, Color textColor, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          trailing: Icon(icon, color: Colors.blue),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sectionColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value, Color textColor, Function(String) onSave) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(color: textColor)),
    );
  }
}
