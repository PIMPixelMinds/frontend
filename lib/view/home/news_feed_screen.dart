import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '/data/repositories/news_service.dart';
import '../home/widgets/news_card.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  late Future<List<dynamic>> news;

  @override
  void initState() {
    super.initState();
    news = fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
       appBar: AppBar(
        title: const Text("MS News Feed", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850], // Darker AppBar Background
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      
      body: FutureBuilder<List<dynamic>>(
        future: news,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return _buildErrorUI();
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var article = snapshot.data![index];
              return NewsCard(
                title: article['title'],
                imageUrl: article['image'] ?? '',
                
                link: article['link'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[800]!, // Darker shimmer effect
          highlightColor: Colors.grey[600]!,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          SizedBox(height: 10),
          Text("Failed to fetch news.", style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() {
              news = fetchNews();
            }),
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No news available.",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
