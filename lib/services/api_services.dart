import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';

class ApiService {
  static const String apiKey = "d54394df4f9a4292b1379ce72952bcdd";
  static const String baseUrl = "https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey";

  Future<List<NewsArticle>> fetchNews(int page) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl&page=$page"));
      print('response.statusCode  ${response.statusCode}');
      print('response.body  ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> articles = jsonData['articles'];
        return articles.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }
}