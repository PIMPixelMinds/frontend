import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';

class BodyPage extends StatefulWidget {
  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> with SingleTickerProviderStateMixin {
  BodyParts _selectedParts = const BodyParts();
  bool isFrontView = true;
  GlobalKey _globalKey = GlobalKey();
  TextEditingController _descriptionController = TextEditingController();
  String? _token;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _loadToken();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
    print("✅ JWT Token loaded: $_token");
  }

  void _onBodyPartSelected(BodyParts parts) {
    setState(() {
      _selectedParts = parts;
    });
  }

  Future<void> _captureAndUploadScreenshot(String? token) async {
    if (_descriptionController.text.isEmpty) {
      _showErrorDialog("Please describe your pain.");
      return;
    }

    if (token == null || token.isEmpty) {
      _showErrorDialog("Error: You must be logged in!");
      return;
    }

    if (_globalKey.currentContext == null) {
      _showErrorDialog("Error during screenshot capture.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("Error converting image.");
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/screenshot.png');
      await file.writeAsBytes(pngBytes);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.saveHistoriqueEndpoint),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields['userText'] = _descriptionController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'screenshot',
        file.path,
        contentType: MediaType('image', 'png'),
      ));

      var response = await request.send();
      String responseString = await response.stream.bytesToString();

      print("🔍 Server response: $responseString");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSuccessDialog();
      } else {
        print("❌ HTTP Error ${response.statusCode} : $responseString");
        throw Exception("HTTP Error ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("An error occurred!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDescriptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Describe the pain",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "e.g. I feel pain in my arm...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _captureAndUploadScreenshot(_token);
                },
                icon: Icon(Icons.send),
                label: Text("Send"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("✅ Success"),
        content: Text("Your screenshot has been successfully uploaded!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/healthPage');
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("⚠️ Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue, // 🔵 AppBar in blue
        title: Text("Select a body part"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {
              setState(() {
                isFrontView = !isFrontView;
                isFrontView
                    ? _animationController.reverse()
                    : _animationController.forward();
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_flipAnimation.value * 3.14),
                  child: child,
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                child: BodyPartSelector(
                  bodyParts: _selectedParts,
                  onSelectionUpdated: _onBodyPartSelected,
                  side: isFrontView ? BodySide.front : BodySide.back,
                  selectedColor: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : FloatingActionButton.extended(
                  onPressed: _showDescriptionSheet,
                  label: Text("Describe"),
                  icon: Icon(Icons.edit),
                  backgroundColor: AppColors.primaryBlue,
                ),
        ],
      ),
    );
  }
}