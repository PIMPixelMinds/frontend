import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pim/core/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class BodyPage extends StatefulWidget {
  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  BodyParts _selectedParts = const BodyParts(); // Initialisation correcte
  bool isFrontView = true; // Vue par défaut
  GlobalKey _globalKey = GlobalKey();
  TextEditingController _descriptionController = TextEditingController();
  String? _token; // Stocker le token JWT

  void _onBodyPartSelected(BodyParts parts) {
    setState(() {
      _selectedParts = parts;
    });
  }
  @override
void initState() {
  super.initState();
  _loadToken();
}

Future<void> _loadToken() async {
  // Exemple avec SharedPreferences (si tu veux stocker localement)
   final prefs = await SharedPreferences.getInstance();
  setState(() {
     _token = prefs.getString('token');
   });

  // OU, si tu reçois le token via une API ou une autre source :
  //String fakeToken = "ton_token_jwt"; // Remplace ceci par ton vrai token
  //setState(() {
   // _token = fakeToken;
  //});

  print("✅ Token JWT chargé : $_token");
}


Future<void> _captureAndUploadScreenshot(String? token) async {
  if (_descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez décrire la douleur.")),
    );
    return;
  }

  if (token == null || token.isEmpty) {
    print('🔴 Erreur : Token JWT manquant !');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur : Token JWT manquant !")),
    );
    return;
  }

 
    // Vérifier si le contexte est valide
    if (_globalKey.currentContext == null) {
      throw Exception("Le contexte du widget est nul !");
    }

    // Capturer l'écran
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      throw Exception("Erreur lors de la conversion de l'image.");
    }

    Uint8List pngBytes = byteData.buffer.asUint8List();

    // Sauvegarder temporairement l'image
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/screenshot.png');
    await file.writeAsBytes(pngBytes);

    // Construire la requête multipart
   var request = http.MultipartRequest(
  'POST', Uri.parse(ApiConstants.saveHistoriqueEndpoint)
);

    request.headers.addAll({
  'Authorization': 'Bearer $token',
});

    request.fields['userText'] = _descriptionController.text;

    request.files.add(await http.MultipartFile.fromPath(
    'screenshot',
  file.path,
  contentType: MediaType('image', 'png'),
));

    print("🟢 Fichier ajouté : ${file.path}");
    print("🟢 Champs envoyés : ${request.fields}");
print("🟢 Capture en cours...");
print("🟢 Chemin du fichier temporaire : ${file.path}");
print("🟢 Champs envoyés : ${request.fields}");

    var response = await request.send();

    if (response.statusCode == 200) {
  print("✅ Upload réussi !");
    } else {
  print("❌ Erreur HTTP ${response.statusCode} : ${await response.stream.bytesToString()}");
    }

  }
  

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionnez une partie du corps"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {
              setState(() {
                isFrontView = !isFrontView;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: BodyPartSelector(
                  bodyParts: _selectedParts,
                  onSelectionUpdated: _onBodyPartSelected,
                  side: isFrontView ? BodySide.front : BodySide.back,
                  selectedColor: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Décrivez la douleur...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
  onPressed: () {
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur : Vous devez être connecté pour envoyer la capture.")),
      );
    } else {
      _captureAndUploadScreenshot(_token);
    }
  },
  child: const Text("Envoyer la capture"),
),
          ],
        ),
      ),
    );
  }
}