import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pim/core/constants/api_constants.dart';

class HealthTrackerRepository {
  // Existing method to get activities
  Future<List<dynamic>> getActivities() async {
    final url = Uri.parse(ApiConstants.fetchActivitiesEndpoint);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      throw Exception('Error fetching activities: $e');
    }
  }
  //************************************************************************************

  // New method to fetch the count of upcoming appointments
  Future<int> getUpcomingAppointmentsCount() async {
    final url = Uri.parse(ApiConstants.countAppointmentsEndpoint);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming the response contains a message with the count of upcoming appointments
        final appointmentsCount = int.parse(data['message'].split(':')[1].split('|')[0].trim());
        return appointmentsCount;
      } else {
        throw Exception('Failed to fetch appointments count');
      }
    } catch (e) {
      throw Exception('Error fetching appointments count: $e');
    }
  }
  //************************************************************************************
  // Method to fetch the recent completed appointments
  Future<List<dynamic>> getCompletedAppointments() async {
    final url = Uri.parse(ApiConstants.fetchCompletedAppointmentsEndpoint);

    try {
      final response = await http.get(url);

      // Print the raw response to debug the structure
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Print the decoded data to see the structure
        print('Decoded Data: $data');

        // Check if the response contains the necessary key 'appointment'
        if (data.containsKey('appointment')) {
          // Print the completed appointments to verify the structure
          print('Completed Appointments: ${data['appointment']}');

          return List<dynamic>.from(data['appointment']);
        } else {
          // Print if the key 'appointment' is missing
          print('No completed appointments found in the response');
          throw Exception('No completed appointments found');
        }
      } else {
        // Print the error message if the status code is not 200
        print('Failed to fetch completed appointments. Status Code: ${response.statusCode}');
        throw Exception('Failed to fetch completed appointments');
      }
    } catch (e) {
      // Catch any exceptions and print the error
      print('Error: $e');
      throw Exception('Error fetching completed appointments: $e');
    }
  }

}
