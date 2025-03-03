import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pim/core/constants/app_colors.dart';
import 'package:pim/viewmodel/medication_viewmodel.dart';
import 'package:provider/provider.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController capSizeController;
  late TextEditingController causeController;
  String? _selectedAmount;
  String? _selectedUnit;
  String? _selectedDuration;
  String? _selectedFrequency;
  List<String> _selectedSchedules = []; // Liste pour plusieurs horaires
  File? _photo; // Utiliser File pour la photo prise avec image_picker

  // Listes pour les dropdowns
  final List<String> _amountOptions = List.generate(30, (index) => (index + 1).toString());
  final List<String> _unitOptions = ['Pill', 'mg', 'mL'];
  final List<String> _durationOptions = ['1 Month', '2 Months', '3 Months', 'Ongoing'];
  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'Monthly', 'As Needed'];

  // Listes des horaires disponibles
  final List<String> _scheduleOptions = [
    'Before Breakfast',
    'Before Dinner',
    'Before Lunch',
    'Before Meals',
    'After Breakfast',
    'After Dinner',
    'After Lunch',
    'After Meals',
  ];
  bool _showAllSchedules = false; // Contrôler l’affichage des horaires supplémentaires

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    capSizeController = TextEditingController();
    causeController = TextEditingController();
    // Définir des valeurs par défaut
    _selectedDuration = '1 Month'; // Valeur par défaut pour Duration
    _selectedFrequency = 'Daily'; // Valeur par défaut pour Frequency
  }

  @override
  void dispose() {
    nameController.dispose();
    capSizeController.dispose();
    causeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Confirm Addition', style: TextStyle(color: AppColors.primaryBlue)),
          content: const Text('Are you sure you want to add this reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Ferme l'alerte
                final viewModel = context.read<MedicationViewModel>();
                viewModel
                    .createMedication(
                  context,
                  name: nameController.text,
                  amount: int.tryParse(_selectedAmount ?? '1') ?? 1,
                  unit: _selectedUnit ?? 'Pill',
                  duration: _selectedDuration ?? '1 Month',
                  capSize: capSizeController.text,
                  cause: causeController.text,
                  frequency: _selectedFrequency ?? 'Daily',
                  schedule: _selectedSchedules.join(', '), // Joindre les horaires sélectionnés
                  photoPath: _photo?.path, // Passer le chemin de la photo
                )
                    .then((_) {
                  if (mounted) { // Vérifier si le widget est encore actif
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Medication added successfully!')),
                    );
                    Navigator.pushReplacementNamed(context, '/medications'); // Retour à MedicationsScreen
                  }
                }).catchError((error) {
                  if (mounted) { // Vérifier si le widget est encore actif
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add medication: $error')),
                    );
                    print("Erreur lors de l’ajout du médicament : $error");
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer le titre
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20), // Icône d’ajout
            const SizedBox(width: 8),
            const Text(
              'Add Reminder',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icône centrale en haut
                Center(
                  child: const Icon(
                    Icons.medical_services,
                    color: AppColors.primaryBlue,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 24),
                // Disposition en grille pour un design esthétique
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name',
                          hintText: 'Test Medication',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAmount,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _amountOptions.map((amount) {
                          return DropdownMenuItem<String>(
                            value: amount,
                            child: Text(amount, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedAmount = value),
                        validator: (value) =>
                            value == null ? 'Please select an amount' : null,
                        dropdownColor: Colors.white, // Fond blanc pour le dropdown
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _unitOptions.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedUnit = value),
                        validator: (value) =>
                            value == null ? 'Please select a unit' : null,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _durationOptions.map((duration) {
                          return DropdownMenuItem<String>(
                            value: duration,
                            child: Text(duration, style:  TextStyle(fontSize: 14, color: Colors.blue[900])),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedDuration = value),
                        validator: (value) =>
                            value == null ? 'Please select a duration' : null,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: capSizeController,
                        decoration: InputDecoration(
                          labelText: 'Cap Size (e.g., 150mg 1 Capsule)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter cap size' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _frequencyOptions.map((freq) {
                          return DropdownMenuItem<String>(
                            value: freq,
                            child: Text(freq, style: const TextStyle(fontSize: 14, color: Colors.red)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedFrequency = value),
                        validator: (value) =>
                            value == null ? 'Please select a frequency' : null,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: causeController,
                  decoration: InputDecoration(
                    labelText: 'Cause (e.g., Alzheimer’s)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a cause' : null,
                ),
                const SizedBox(height: 16),
                // Champs de Schedule en liste horizontale avec bouton "+"
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time & Schedule',
                    labelStyle:  TextStyle(color: Colors.grey[600], fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200], // Fond gris clair comme dans la capture
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...(_showAllSchedules
                                ? _scheduleOptions.map((schedule) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_selectedSchedules.contains(schedule)) {
                                              _selectedSchedules.remove(schedule);
                                            } else {
                                              _selectedSchedules.add(schedule);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _selectedSchedules.contains(schedule)
                                              ? (schedule.toLowerCase().contains('breakfast')
                                                  ? Colors.green[100]!
                                                  : Colors.pink[100]!)
                                              : Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        child: Text(
                                          schedule,
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : _scheduleOptions.take(2).map((schedule) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_selectedSchedules.contains(schedule)) {
                                              _selectedSchedules.remove(schedule);
                                            } else {
                                              _selectedSchedules.add(schedule);
                                            }
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _selectedSchedules.contains(schedule)
                                              ? (schedule.toLowerCase().contains('breakfast')
                                                  ? Colors.green[100]!
                                                  : Colors.pink[100]!)
                                              : Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        child: Text(
                                          schedule,
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                      ),
                                    );
                                  }).toList()),
                            if (!_showAllSchedules)
                              IconButton(
                                icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                                onPressed: () {
                                  setState(() {
                                    _showAllSchedules = true;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      if (_showAllSchedules)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllSchedules = false;
                            });
                          },
                          child: const Text(
                            'Show Less',
                            style: TextStyle(color: AppColors.primaryBlue, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Widget pour afficher la photo
                if (_photo != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _photo!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                // Boutons pour prendre ou uploader une photo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Take Photo',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upload Photo',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Bouton "Add Reminder" centré en bas
                Center(
                  child: ElevatedButton(
                    onPressed: () => _submitForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text(
                      'Add Reminder',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}