import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Pour télécharger l'image
import 'package:path_provider/path_provider.dart'; // Pour gérer les fichiers temporaires
import 'package:pim/core/constants/app_colors.dart';
import 'package:pim/viewmodel/medication_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart'; // Pour SchedulerBinding

class MedicineInfoScreen extends StatefulWidget {
  final String? medicationId; // Utiliser l'ID pour récupérer les données dynamiquement

  const MedicineInfoScreen({super.key, this.medicationId});

  @override
  State<MedicineInfoScreen> createState() => _MedicineInfoScreenState();
}

class _MedicineInfoScreenState extends State<MedicineInfoScreen> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController unitController;
  late TextEditingController durationController;
  late TextEditingController capSizeController;
  late TextEditingController causeController;
  late TextEditingController frequencyController;
  late TextEditingController scheduleController;
  bool isActive = true;
  bool _isLoading = false;
  File? _photo; // Pour gérer la photo si elle existe

  // Listes des horaires disponibles
  final List<String> _scheduleOptions = [
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Before Meals',
    'After Meals',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchMedicationIfNeeded();
  }

  void _initializeControllers() {
    // Initialiser avec des valeurs par défaut ou les données du médicament
    nameController = TextEditingController();
    amountController = TextEditingController();
    unitController = TextEditingController(text: 'Pill');
    durationController = TextEditingController(text: '1 Month');
    capSizeController = TextEditingController();
    causeController = TextEditingController();
    frequencyController = TextEditingController(text: 'Daily');
    scheduleController = TextEditingController(text: 'Before Breakfast');
    isActive = true;
  }

  Future<void> _fetchMedicationIfNeeded() async {
    if (widget.medicationId != null && widget.medicationId!.isNotEmpty) {
      final viewModel = Provider.of<MedicationViewModel>(context, listen: false);
      setState(() => _isLoading = true);
      try {
        await viewModel.fetchMedication(context, widget.medicationId!);
        if (viewModel.selectedMedication != null) {
          final medication = viewModel.selectedMedication;
          nameController.text = medication['name']?.toString() ?? '';
          amountController.text = medication['amount']?.toString() ?? '';
          unitController.text = medication['unit']?.toString() ?? 'Pill';
          durationController.text = medication['duration']?.toString() ?? '1 Month';
          capSizeController.text = medication['capSize']?.toString() ?? '';
          causeController.text = medication['cause']?.toString() ?? '';
          frequencyController.text = medication['frequency']?.toString() ?? 'Daily';
          scheduleController.text =
              (medication['schedule'] as String?)?.toString() ?? 'Before Breakfast';
          isActive = medication['isActive'] ?? true;

          // Charger la photo si elle existe
          if (medication['photoUrl'] != null) {
            _photo = await _downloadPhoto(medication['photoUrl'] as String);
            setState(() {});
          }
        } else {
          _showError('No medication data available');
        }
      } catch (e) {
        _showError('Failed to fetch medication: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _showError('No medication ID provided');
    }
  }

  Future<File?> _downloadPhoto(String photoUrl) async {
    try {
      final response = await http.get(Uri.parse(photoUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/medication_photo.jpg');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print("Erreur lors du téléchargement de la photo : $e");
      return null;
    }
    return null;
  }

  void _showError(String message) {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
    durationController.dispose();
    capSizeController.dispose();
    causeController.dispose();
    frequencyController.dispose();
    scheduleController.dispose();
    super.dispose();
  }

  void _updateMedication(BuildContext context) {
    final viewModel = context.read<MedicationViewModel>();
    viewModel
        .updateMedication(
      context,
      id: widget.medicationId ?? '',
      name: nameController.text,
      amount: int.tryParse(amountController.text) ?? 0,
      unit: unitController.text,
      duration: durationController.text,
      capSize: capSizeController.text,
      cause: causeController.text,
      frequency: frequencyController.text,
      schedule: scheduleController.text,
      isActive: isActive,
    )
        .then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication updated successfully!')),
        );
        Navigator.pop(context);
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update medication: $error')),
        );
        print("Erreur lors de la mise à jour du médicament : $error");
      }
    });
  }

  void _deleteMedication(BuildContext context) {
    final viewModel = context.read<MedicationViewModel>();
    final id = widget.medicationId;
    if (id == null || id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No medication ID provided')),
        );
      }
      return;
    }
    viewModel
        .deleteMedication(context, id)
        .then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication deleted successfully!')),
        );
        Navigator.pop(context);
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete medication: $error')),
        );
        print("Erreur lors de la suppression du médicament : $error");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20), // Icône d’information
            const SizedBox(width: 8),
            const Text(
              'Medicine Info',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _deleteMedication(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icône centrale en haut (sac de médicaments)
                    Center(
                      child: const Icon(
                        Icons.local_pharmacy,
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
                          child: TextFormField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter an amount' : null,
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
                            controller: unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please select a unit' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: durationController,
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please select a duration' : null,
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
                          child: TextFormField(
                            controller: frequencyController,
                            decoration: InputDecoration(
                              labelText: 'Frequency',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Please select a frequency' : null,
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
                    // Afficher les horaires dans un ExpansionTile avec défilement horizontal
                    ExpansionTile(
                      title: const Text(
                        'Schedule',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: const Icon(Icons.schedule, color: AppColors.primaryBlue),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _scheduleOptions.map((schedule) {
                              final isSelected = scheduleController.text
                                  .split(', ')
                                  .contains(schedule);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      final schedules = scheduleController.text
                                          .split(', ')
                                          .where((s) => s.isNotEmpty)
                                          .toList();
                                      if (isSelected) {
                                        schedules.remove(schedule);
                                      } else {
                                        schedules.add(schedule);
                                      }
                                      scheduleController.text =
                                          schedules.join(', ').trim();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? (schedule
                                                .toLowerCase()
                                                .contains('breakfast')
                                            ? Colors.green[100]!
                                            : Colors.pink[100]!)
                                        : Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  child: Text(
                                    schedule,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      collapsedBackgroundColor: Colors.white,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                      activeColor: AppColors.primaryBlue, // Couleur bleue primaire pour le switch
                      tileColor: Colors.white, // Fond blanc pour le SwitchListTile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Afficher la photo si elle existe (comme dans AddReminderScreen)
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
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _updateMedication(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        ),
                        child: const Text(
                          'Update Reminder',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}