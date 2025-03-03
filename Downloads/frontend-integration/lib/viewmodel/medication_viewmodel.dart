import 'package:flutter/material.dart';
import 'package:pim/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../data/repositories/medication_repository.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationRepository _medicationRepository = MedicationRepository();
  bool isLoading = false;
  List<dynamic> medications = [];
  dynamic selectedMedication; // For Medicine Info
  String? errorMessage;
  Future<void> fetchAllMedications(BuildContext? context) async {
    if (context == null) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      if (await authViewModel.isTokenExpired()) {
        await authViewModel.refreshToken(context);
      }

      isLoading = true;
      notifyListeners();

      medications = await _medicationRepository.getAllMedications();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
      print("Erreur fetchAllMedications : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMedicationsByFilter(
      BuildContext? context, String filter) async {
    if (context == null) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (!['today', 'week', 'month'].contains(filter.toLowerCase())) {
      errorMessage = 'Invalid filter value. Use "today", "week", or "month".';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
      print("Erreur : Filtre invalide - $filter");
      return;
    }

    try {
      if (await authViewModel.isTokenExpired()) {
        await authViewModel.refreshToken(context);
      }

      isLoading = true;
      notifyListeners();

      await fetchAllMedications(context);

      final now = DateTime.now();
      medications = medications.where((medication) {
        final createdAt = DateTime.parse(medication['createdAt']);
        switch (filter.toLowerCase()) {
          case 'today':
            return isSameDay(createdAt, now);
          case 'week':
            return isSameWeek(createdAt, now);
          case 'month':
            return isSameMonth(createdAt, now);
          default:
            return false;
        }
      }).toList();
      errorMessage = null;

      print("Médicaments filtrés par : $filter - Résultat : $medications");
    } catch (e) {
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
      print("Erreur fetchMedicationsByFilter : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fonctions helpers pour comparer les dates
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isSameWeek(DateTime date1, DateTime date2) {
    final diff = date1.difference(date2).inDays;
    return diff.abs() <= 7 && date1.weekday == date2.weekday;
  }

  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  Future<void> fetchMedication(BuildContext? context, String id) async {
    if (context == null) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      if (await authViewModel.isTokenExpired()) {
        await authViewModel.refreshToken(context);
      }

      isLoading = true;
      notifyListeners();

      selectedMedication = await _medicationRepository.getMedication(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch medication: $e')),
      );
      print("Erreur fetchMedication : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMedication(
    BuildContext? context, {
    required String name,
    required int amount,
    required String unit,
    required String duration,
    required String capSize,
    required String cause,
    required String frequency,
    required String schedule,
    String? photoPath,
  }) async {
    if (context == null) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      if (await authViewModel.isTokenExpired()) {
        await authViewModel.refreshToken(context);
      }

      isLoading = true;
      notifyListeners();

      final response = await _medicationRepository.createMedication(
        name: name,
        amount: amount,
        unit: unit,
        duration: duration,
        capSize: capSize,
        cause: cause,
        frequency: frequency,
        schedule: schedule,
        photoPath: photoPath,
      );

      // Mettre à jour la liste des médicaments après création
      await fetchAllMedications(context);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create medication: $e')),
      );
      print("Erreur createMedication : $e");
      throw e; // Relancer l’erreur pour être capturée par .catchError dans _submitForm
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMedication(
    BuildContext? context, {
    required String id,
    required String name,
    required int amount,
    required String unit,
    required String duration,
    required String capSize,
    required String cause,
    required String frequency,
    required String schedule,
    required bool isActive,
  }) async {
    if (context == null) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      if (await authViewModel.isTokenExpired()) {
        await authViewModel.refreshToken(context);
      }

      isLoading = true;
      notifyListeners();

      await _medicationRepository.updateMedication(
        id: id,
        name: name,
        amount: amount,
        unit: unit,
        duration: duration,
        capSize: capSize,
        cause: cause,
        frequency: frequency,
        schedule: schedule,
        isActive: isActive,
      );

      await fetchAllMedications(
          context); // Mettre à jour la liste des médicaments
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update medication: $e')),
      );
      print("Erreur updateMedication : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedication(BuildContext? context, String id) async {
    if (context == null) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    try {
      if (await authViewModel.isTokenExpired()) {
        await authViewModel.refreshToken(context);
      }

      isLoading = true;
      notifyListeners();

      await _medicationRepository.deleteMedication(id);
      await fetchAllMedications(context); // Mettre à jour la liste des médicaments
      errorMessage = null;

      // Vérifier si le context est toujours monté avant d’afficher le SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication deleted successfully!')),
        );
      }
    } catch (e) {
      errorMessage = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete medication: $e')),
        );
      }
      print("Erreur deleteMedication : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}