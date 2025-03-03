//BECHA
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  final String link;

  const NewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.link, // Add this parameter
  });

  void _launchURL() async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url)) {
      throw Exception("Could not open $link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL, // Open the website when tapped
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(imageUrl,
                    width: double.infinity, height: 200, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
