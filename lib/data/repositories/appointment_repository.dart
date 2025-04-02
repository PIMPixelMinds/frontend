import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pim/core/constants/api_constants.dart';
import 'package:pim/data/model/appointment_mode.dart';

class AppointmentRepository {
  Future<Appointment> addAppointment(
      Appointment appointment, String token) async {
    final url = Uri.parse(ApiConstants.addAppointmentEndpoint);

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "fullName": appointment.fullName.trim(),
          "date": appointment.date.toLocal().toIso8601String(),
          "phone": appointment.phone,
          "status": appointment.status,
          "fcmToken": appointment.fcmToken,
        }),
      );

      if (response.statusCode == 201) {
        return Appointment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)["message"] ??
            "Appointment Registration Failed");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<Appointment> updateAppointment(String name,
      {required String newFullName,
      required String newDate,
      required String newPhone}) async {
    final url = Uri.parse("${ApiConstants.updateAppointmentEndpoint}/$name");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "newFullName": newFullName,
        "newDate": newDate,
        "newPhone": newPhone,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)["message"] ??
          "Failed to update appointment");
    }
  }

  Future<void> cancelAppointment(String name) async {
    final url = Uri.parse("${ApiConstants.cancelAppointmentEndpoint}/$name");

    final response = await http.put(
      url,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel appointment");
    }
  }

  Future<Map<String, dynamic>> displayAppointments(String token) async {
    final url = Uri.parse(ApiConstants.displayAppointmentEndpoint);

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)["message"] ??
          "Failed to fetch appointments");
    }
  }
}
