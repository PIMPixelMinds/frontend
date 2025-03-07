import 'package:flutter/material.dart';
import 'package:pim/core/constants/app_colors.dart';
import 'package:pim/viewmodel/medication_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/scheduler.dart'; // Pour les animations

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _currentFilter = 'today';

  late AnimationController
      _loadingAnimationController; // Pour l'animation de chargement
  Map<String, bool> _medicationTakenStatus =
      {}; // État local pour suivre les médicaments pris

  // Clé globale pour le ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<MedicationViewModel>();
      viewModel.fetchMedicationsByFilter(context, _currentFilter);
    });
  }

  void _onFilterChanged(String filter) {
    if (!mounted) return;
    setState(() {
      _currentFilter = filter;
    });
    final viewModel = context.read<MedicationViewModel>();
    viewModel.fetchMedicationsByFilter(context, _currentFilter);
  }

  void _toggleMedicationTaken(String medicationId) {
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _medicationTakenStatus[medicationId] =
            !(_medicationTakenStatus[medicationId] ?? false);
      });
      // Alternative à l'animation de chargement : afficher une coche persistante
      // Si l'animation ne fonctionne pas, vous pouvez commenter cette partie et utiliser uniquement l'état visuel
      _loadingAnimationController.forward().then((_) {
        _loadingAnimationController.reverse();
      });
    });
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey, // Clé globale pour le ScaffoldMessenger
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer le titre
          children: [
            const Icon(Icons.local_pharmacy,
                color: Colors.white, size: 20), // Icône de pharmacie
            const SizedBox(width: 8),
            Text(
              'Medications',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold, // En gras
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        // Défilement complet de la page
        child: Consumer<MedicationViewModel>(
          builder: (context, viewModel, child) {
            final selectedDate = _selectedDay ?? _focusedDay;
            final isAllTaken = viewModel.medications.every((medication) =>
                _medicationTakenStatus[medication['_id'].toString()] ?? false);

            return Column(
              children: [
                Container(
                  height: 400,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2022, 1, 1),
                    lastDay: DateTime.utc(2026, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(day, _selectedDay!),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!mounted) return;
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      if (!mounted) return;
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: isAllTaken
                            ? Colors.green
                            : Colors.grey[300], // Vert si tous pris
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => _onFilterChanged('today'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentFilter == 'today'
                              ? Colors.blue[
                                  900] // Bleu foncé pour le filtre sélectionné
                              : AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Today',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () => _onFilterChanged('week'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentFilter == 'week'
                              ? Colors.blue[
                                  900] // Bleu foncé pour le filtre sélectionné
                              : AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Week',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () => _onFilterChanged('month'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentFilter == 'month'
                              ? Colors.blue[
                                  900] // Bleu foncé pour le filtre sélectionné
                              : AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Month',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                // Ajuster la hauteur pour permettre le défilement complet
                Container(
                  padding: const EdgeInsets.only(
                      bottom: 80), // Espace pour le FloatingActionButton
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                          ? Center(
                              child: Text(viewModel
                                  .errorMessage!)) // Correction ici : viewModel au lieu de viewMessage
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.medications.length,
                              itemBuilder: (context, index) {
                                final medication = viewModel.medications[index];
                                final medicationId =
                                    medication['_id'].toString();
                                final isTaken =
                                    _medicationTakenStatus[medicationId] ??
                                        false;
                                return _buildMedicationCard(
                                    medication, medicationId, isTaken);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            Navigator.pushNamed(context, '/addReminder');
          } catch (e) {
            if (mounted) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text("Erreur navigation : $e")),
              );
            }
            print("Erreur navigation vers /addReminder : $e");
          }
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMedicationCard(
      Map<String, dynamic> medication, String medicationId, bool isTaken) {
    final schedule = (medication['schedule'] as String?)?.split(', ') ?? [];

    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_pharmacy,
          color: AppColors.primaryBlue,
          size: 40,
        ),
      ),
      title: Text(
        medication['name'] ?? 'Unknown Medication',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${medication['capSize'] ?? 'N/A'}'),
          const SizedBox(height: 8),
          // Champs de "schedule" avec couleur bleu ciel
          Wrap(
            spacing: 8,
            children: schedule.map((scheduleItem) {
              return _buildScheduleChip(scheduleItem);
            }).toList(),
          ),
        ],
      ),
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Learn More'),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  if (mounted) {
                    Navigator.pushNamed(
                      context,
                      '/medicineInfo',
                      arguments: medication['_id'].toString(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delete'),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                onPressed: () async {
                  if (mounted) {
                    final viewModel = context.read<MedicationViewModel>();
                    await viewModel.deleteMedication(context, medicationId);
                  }
                },
              ),
            ],
          ),
        ),
      ],
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      collapsedBackgroundColor: isTaken
          ? Colors.green[100]
          : Colors.white, // Changer la couleur si pris
      backgroundColor: isTaken
          ? Colors.green[100]
          : Colors.white, // Changer la couleur si pris
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      trailing: IconButton(
        icon: Icon(
          isTaken ? Icons.check_circle : Icons.circle_outlined,
          color: isTaken ? Colors.green : Colors.grey,
        ),
        onPressed: () {
          _toggleMedicationTaken(medicationId);
        },
      ),
    );
  }

  Widget _buildScheduleChip(String scheduleItem) {
    const skyBlue =
        Color.fromARGB(255, 135, 206, 235); // Bleu ciel personnalisé
    return Chip(
      label: Text(
        scheduleItem,
        style: const TextStyle(color: Colors.black87, fontSize: 12),
      ),
      backgroundColor: skyBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}