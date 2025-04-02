import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

String formatDate(String createdAt) {
  DateTime date = DateTime.parse(createdAt);
  return DateFormat('dd MMM yyyy HH:mm').format(date);
}

class HistoryRepository {
  final GlobalKey globalKey;

  HistoryRepository(this.globalKey);

  /*Future<void> captureAndUploadScreenshot(String token) async {
    try {
      // 🔹 Capture de l'image
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 🔹 Sauvegarde temporaire
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/screenshot.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // 🔹 Envoi au backend
      final url = Uri.parse(ApiConstants.uploadScreenshotEndpoint);
      var request = http.MultipartRequest('POST', url);
      
      // Ajout du token
      request.headers["Authorization"] = "Bearer $token";
      request.files.add(await http.MultipartFile.fromPath(
  'screenshot', 
  filePath, 
  contentType: MediaType('image', 'png'), // Définit bien le type MIME
));


      var response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Capture envoyée avec succès !");
      } else {
        throw Exception(jsonDecode(responseBody)['message'] ?? "Erreur d'envoi");
      }
    } catch (e) {
      print("❌ Erreur capture : $e");
      throw Exception("Erreur lors de la capture et de l'upload : $e");
    }
  }*/

  // 🔹 Récupérer l'historique des captures d'écran
  /*Future<List<Map<String, dynamic>>> getHistory(String token) async {
    try {
      final url = Uri.parse(ApiConstants.getHistoryEndpoint);
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? "Erreur récupération historique");
      }
    } catch (e) {
      print("❌ Erreur API : $e");
      throw Exception("Impossible de récupérer l'historique : $e");
    }
  }*/

  static Future<List<dynamic>> getHistorique(String token) async {
    
    final response = await http.get(
      Uri.parse(ApiConstants.getHistoriqueEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération de l'historique");
    }
  }

  // Dans ton repository :
static Future<List<dynamic>> getGroupedHistorique(String token) async {
  final response = await http.get(
    Uri.parse(ApiConstants.getGroupedHistoriqueEndpoint),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Erreur lors de la récupération de l'historique groupé");
  }
}
}
