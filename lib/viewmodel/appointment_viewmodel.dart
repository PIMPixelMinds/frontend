import 'package:flutter/material.dart';
import 'package:pim/data/model/appointment_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/appointment_repository.dart';

class AppointmentViewModel extends ChangeNotifier {
  final AppointmentRepository _repository = AppointmentRepository();

  bool isLoading = false;
  String? errorMessage;
  List<Appointment> appointments = [];

  Future<void> addAppointment(Appointment appointment) async {
    isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("No token found. Please log in again.");
    }
    try {
      await _repository.addAppointment(appointment, token);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointment(String name,
      {required String newFullName,
      required String newDate,
      required String newPhone}) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.updateAppointment(name,
          newFullName: newFullName, newDate: newDate, newPhone: newPhone);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String name) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.cancelAppointment(name);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAppointments() async {
    isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    try {
      final data = await _repository.displayAppointments(token!);
      appointments = (data['appointment'] as List)
          .map((item) => Appointment.fromJson(item))
          .toList();
      errorMessage = '';
    } catch (error) {
      errorMessage = error.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
