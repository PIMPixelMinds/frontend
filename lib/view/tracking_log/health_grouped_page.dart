import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/historique_repository.dart';
import '../../core/constants/app_colors.dart';

class HealthGroupedPage extends StatefulWidget {
  @override
  _HealthGroupedPageState createState() => _HealthGroupedPageState();
}

class _HealthGroupedPageState extends State<HealthGroupedPage> {
  List<dynamic> groupedHistorique = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchGroupedHistorique();
  }

  Future<void> fetchGroupedHistorique() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    if (token == null) {
      print("❌ Aucun token trouvé !");
      return;
    }

    try {
      List<dynamic> data = await HistoryRepository.getGroupedHistorique(token!);
      setState(() {
        groupedHistorique = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Erreur : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDateTitle(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('EEEE, dd MMMM yyyy').format(date);
  }

  String formatTime(String dateTimeStr) {
    DateTime dt = DateTime.parse(dateTimeStr);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupedHistorique.isEmpty
              ? Center(
                  child: Text(
                    "No pain records available.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: groupedHistorique.length,
                  itemBuilder: (context, index) {
                    var section = groupedHistorique[index];
                    String date = section['date'];
                    List<dynamic> records = section['records'];

                    return _buildDateSection(date, records);
                  },
                ),
    );
  }

  Widget _buildDateSection(String date, List<dynamic> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Date Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            formatDateTitle(date),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        // 🔹 Records List
        ...records.map((record) => _buildPainCard(record)).toList(),
      ],
    );
  }

  Widget _buildPainCard(dynamic record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: AppColors.primaryBlue.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Image
            Center(
  child: ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    child: Image.network(
      "http://192.168.200.201:3000${record['imageUrl']}",
      width: 250,
      height: 250,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 250,
        height: 250,
        color: Colors.grey.shade300,
        child: Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 250,
          height: 250,
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
      },
    ),
  ),
),
            // Description + Heure
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['generatedDescription'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        formatTime(record['createdAt']),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}