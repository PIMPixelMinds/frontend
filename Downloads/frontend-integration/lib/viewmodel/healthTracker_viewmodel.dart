import 'package:flutter/material.dart';
import 'package:pim/data/repositories/healthtracker_repository.dart';

class HealthTrackerViewModel extends ChangeNotifier {
  final HealthTrackerRepository _repository = HealthTrackerRepository();

  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> activities = [];
  List<dynamic> completedAppointments = [];


  // Variable to store the count of upcoming appointments
  int upcomingAppointmentsCount = 0;

  Future<void> fetchActivities(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final fetchedActivities = await _repository.getActivities();

      if (fetchedActivities.isEmpty) {
        errorMessage = "No activities available.";
      }

      activities = fetchedActivities;
    } catch (e) {
      errorMessage = "Error: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  //************************************************************************************

  // Method to fetch the upcoming appointments count
  Future<void> fetchUpcomingAppointmentsCount(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      upcomingAppointmentsCount = await _repository.getUpcomingAppointmentsCount();
    } catch (e) {
      errorMessage = "Error: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
//************************************************************************************
// Method to fetch the recent completed appointments
  Future<void> fetchCompletedAppointments(BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      // Fetch the completed appointments from the repository
      final fetchedCompletedAppointments = await _repository.getCompletedAppointments();

      // Cast the dynamic list to a list of maps
      if (fetchedCompletedAppointments.isNotEmpty) {
        completedAppointments = List<Map<String, dynamic>>.from(fetchedCompletedAppointments);
      } else {
        errorMessage = "No completed appointments found.";
      }

      notifyListeners();
    } catch (e) {
      errorMessage = "Error: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
