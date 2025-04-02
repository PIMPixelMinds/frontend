import 'package:flutter/material.dart';
import 'package:pim/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/historique_repository.dart';

class HealthPage extends StatefulWidget {
  @override
  _HealthPageState createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  List<dynamic> historique = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchHistorique();
  }

  Future<void> fetchHistorique() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString(
        "token"); // Assure-toi que tu stockes le token lors de la connexion
    print(" token : $token");
    if (token == null) {
      print("❌ Aucun token trouvé !");
      return;
    }

    try {
      List<dynamic> data = await HistoryRepository.getHistorique(token!);
      setState(() {
        historique = data;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pain History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
      ),
      
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : historique.isEmpty
              ? Center(child: Text("No history available."))
              : ListView.builder(
                  itemCount: historique.length,
                  itemBuilder: (context, index) {
                    var item = historique[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.network(
                              "http://192.168.200.201:3000${item['imageUrl']}",
                              width: 250,
                              height: 250,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item['generatedDescription'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              formatDate(item['createdAt']),
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
