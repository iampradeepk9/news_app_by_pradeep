import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/news_provider.dart';
import 'news_details_page.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Latest News",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => newsProvider.loadNews(refresh: true),
          ),
        ],
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async => newsProvider.loadNews(refresh: true),
        child: newsProvider.isLoading && newsProvider.articles.isEmpty
            ? _buildShimmerEffect()
            : newsProvider.errorMessage.isNotEmpty
            ? _buildErrorUI(newsProvider.errorMessage, context)
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: newsProvider.articles.length,
          itemBuilder: (context, index) {
            final article = newsProvider.articles[index];
            return _buildNewsCard(article, context);
          },
        ),
      ),
    );
  }

  String formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }

  Widget _buildNewsCard(article, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailsPage(article: article)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(
              article.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                );
              },
            )
                : Container(
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        formatDate(article.publishedAt), // Use formatted date
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    article.description.isNotEmpty ? article.description : "No description available.",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              children: [
                Container(height: 200, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, width: double.infinity, color: Colors.grey),
                      const SizedBox(height: 5),
                      Container(height: 14, width: 100, color: Colors.grey),
                      const SizedBox(height: 8),
                      Container(height: 14, width: double.infinity, color: Colors.grey),
                      const SizedBox(height: 5),
                      Container(height: 14, width: double.infinity, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorUI(String errorMessage, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(
              "Oops! Something went wrong.",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Provider.of<NewsProvider>(context, listen: false).loadNews(refresh: true),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}