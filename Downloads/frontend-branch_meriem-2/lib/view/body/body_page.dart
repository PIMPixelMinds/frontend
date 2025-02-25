import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class BodyPage extends StatefulWidget {
  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  bool isMale = true; // Genre de l'utilisateur
  bool isColoringMode = false; // Mode de coloriage activé/désactivé
  Map<String, Color> selectedParts = {}; // Suivre les parties sélectionnées
  Color selectedColor = Colors.red; // Couleur par défaut pour le coloriage

  void toggleGender() {
    setState(() {
      isMale = !isMale;
      selectedParts.clear(); // Réinitialiser les parties sélectionnées lors du changement de genre
    });
  }

  void toggleColoringMode() {
    setState(() {
      isColoringMode = !isColoringMode; // Activer/Désactiver le mode coloriage
    });
  }

  void selectPart(String part) {
    setState(() {
      if (selectedParts.containsKey(part)) {
        selectedParts.remove(part); // Désélectionner la partie si déjà sélectionnée
      } else {
        selectedParts[part] = selectedColor; // Sélectionner la partie avec la couleur choisie
      }
    });
  }

  void changeColor(Color color) {
    setState(() {
      selectedColor = color; // Mettre à jour la couleur sélectionnée
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: toggleGender,
                        icon: Icon(isMale ? Icons.male : Icons.female, color: Colors.blue, size: 30),
                        label: Text(
                          isMale ? "Homme" : "Femme",
                          style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.blue, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: toggleColoringMode,
                        child: Text(
                          isColoringMode ? "Rotation" : "Coloriage",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isColoringMode ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: isColoringMode, // Bloquer les interactions lorsque le mode coloriage est activé
                        child: ModelViewer(
                          key: ValueKey(isMale),
                          src: isMale ? "assets/male.glb" : "assets/Female.glb",
                          alt: "Modèle 3D du corps humain",
                          ar: true,
                          autoRotate: true,
                          cameraControls: !isColoringMode, // Désactiver les contrôles de caméra en mode coloriage
                          iosSrc: isMale ? "assets/male.glb" : "assets/Female.glb",
                          loading: Loading.eager,
                        ),
                      ),
                      if (isColoringMode)
                        Positioned.fill(
                          child: GestureDetector(
                            onTapDown: (details) {
                              Offset tapPosition = details.localPosition;
                              double x = tapPosition.dx;
                              double y = tapPosition.dy;

                              // Ajustez les coordonnées selon la taille du modèle 3D
                              if (x < 150 && y > 50 && y < 200) {
                                selectPart("bras_gauche");
                              } else if (x > 150 && x < 300 && y > 50 && y < 200) {
                                selectPart("bras_droit");
                              } else if (x > 100 && x < 300 && y > 200 && y < 400) {
                                selectPart("torse");
                              } else if (x > 150 && x < 250 && y > 400 && y < 550) {
                                selectPart("jambe_gauche");
                              } else if (x > 250 && x < 350 && y > 400 && y < 550) {
                                selectPart("jambe_droite");
                              }
                            },
                          ),
                        ),
                      if (isColoringMode)
                        ...selectedParts.entries.map((entry) {
                          String part = entry.key;
                          Color color = entry.value;
                          return Positioned(
                            child: CustomPaint(
                              painter: PartPainter(part: part, color: color),
                              child: Container(),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var part in selectedParts.keys)
                        Chip(
                          label: Text(part),
                          backgroundColor: selectedParts[part],
                          deleteIcon: Icon(Icons.close, size: 16, color: Colors.white),
                          onDeleted: () {
                            selectPart(part); // Supprimer la partie sélectionnée
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isColoringMode)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Choisissez une couleur"),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              onColorSelected: changeColor,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.color_lens, size: 30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Classe pour dessiner les parties sélectionnées
class PartPainter extends CustomPainter {
  final String part;
  final Color color;

  PartPainter({required this.part, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Dessiner les zones spécifiques
    switch (part) {
      case "bras_gauche":
        canvas.drawRect(Rect.fromLTWH(50, 50, 100, 150), paint); // Bras gauche
        break;
      case "bras_droit":
        canvas.drawRect(Rect.fromLTWH(200, 50, 100, 150), paint); // Bras droit
        break;
      case "torse":
        canvas.drawRect(Rect.fromLTWH(100, 200, 200, 200), paint); // Torse
        break;
      case "jambe_gauche":
        canvas.drawRect(Rect.fromLTWH(150, 400, 100, 150), paint); // Jambe gauche
        break;
      case "jambe_droite":
        canvas.drawRect(Rect.fromLTWH(250, 400, 100, 150), paint); // Jambe droite
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Widget pour le sélecteur de couleur
class ColorPicker extends StatelessWidget {
  final Function(Color) onColorSelected;

  const ColorPicker({required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      children: List.generate(20, (index) {
        Color color = Colors.primaries[index % Colors.primaries.length];
        return InkWell(
          onTap: () => onColorSelected(color),
          child: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            width: 50,
            height: 50,
          ),
        );
      }),
    );
  }
}