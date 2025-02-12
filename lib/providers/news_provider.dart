import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';
import '../services/api_services.dart';

class NewsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _hasError = false;
  String errorMessage = '';
  int _page = 1;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  NewsProvider() {
    loadNews();
  }

  Future<void> loadNews({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _articles.clear();
    }
    _isLoading = true;
    _hasError = false;
    errorMessage = '';
    notifyListeners();

    try {
      List<NewsArticle> fetchedArticles = await _apiService.fetchNews(_page);
      _articles.addAll(fetchedArticles);
      _page++;
      await saveToLocalStorage();
    } catch (e) {
      _hasError = true;
      await loadFromLocalStorage();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonArticles = _articles.map((article) => json.encode(article.toJson())).toList();
    prefs.setStringList('news_data', jsonArticles);
  }

  Future<void> loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedData = prefs.getStringList('news_data');
    if (storedData != null) {
      _articles = storedData.map((jsonStr) => NewsArticle.fromJson(json.decode(jsonStr))).toList();
    }
  }
}
