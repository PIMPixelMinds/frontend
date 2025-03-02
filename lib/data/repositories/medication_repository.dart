import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class MedicationRepository {
  Future<Map<String, dynamic>?> createMedication({
    required String name,
    required int amount,
    required String unit,
    required String duration,
    required String capSize,
    required String cause,
    required String frequency,
    required String schedule,
    String? photoUrl,
    String? photoPath, // Optional for image upload
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/medications');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = name
      ..fields['amount'] = amount.toString()
      ..fields['unit'] = unit
      ..fields['duration'] = duration
      ..fields['capSize'] = capSize
      ..fields['cause'] = cause
      ..fields['frequency'] = frequency
      ..fields['schedule'] = schedule;

    if (photoUrl != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photoUrl));
    }

    final response = await request.send();
    final responseBody = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(
          jsonDecode(responseBody)['message'] ?? 'Failed to create medication');
    }
  }

  Future<List<dynamic>> getAllMedications() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/medications');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to fetch medications');
    }
  }

  Future<List<dynamic>> getMedicationsByFilter(String filter) async {
    final url = Uri.parse(
        '${ApiConstants.getMedicationsByFilterEndpoint}?filter=$filter');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    print("Token envoyé à /medications/filter : $token"); // Log pour déboguer

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(
        "Réponse API medications/filter : ${response.statusCode} - ${response.body}"); // Log pour déboguer

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to fetch filtered medications');
    }
  }

  Future<Map<String, dynamic>?> getMedication(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/medications/$id');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Failed to fetch medication');
    }
  }

  Future<void> updateMedication({
    required String id,
    String? name,
    int? amount,
    String? unit,
    String? duration,
    String? capSize,
    String? cause,
    String? frequency,
    String? schedule,
    bool? isActive,
    String? photoUrl, // Optional for image update
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/medications/$id');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token';

    // Add fields if provided
    if (name != null) request.fields['name'] = name;
    if (amount != null) request.fields['amount'] = amount.toString();
    if (unit != null) request.fields['unit'] = unit;
    if (duration != null) request.fields['duration'] = duration;
    if (capSize != null) request.fields['capSize'] = capSize;
    if (cause != null) request.fields['cause'] = cause;
    if (frequency != null) request.fields['frequency'] = frequency;
    if (schedule != null) request.fields['schedule'] = schedule;
    if (isActive != null) request.fields['isActive'] = isActive.toString();

    if (photoUrl != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photoUrl));
    }

    final response = await request.send();
    final responseBody = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(responseBody)['message'] ?? 'Failed to update medication');
    }
  }

  Future<void> deleteMedication(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/medications/$id');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ??
          'Failed to delete medication');
    }
  }
}
