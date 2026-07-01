import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.categoriesEndpoint}');
      if (kDebugMode) debugPrint('ApiService: Fetching categories from $url');
      
      final response = await _client.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic> dataList = decodedData['data'] ?? [];
        return dataList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw HttpException('Failed to load categories: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('No Internet connection');
    } on Exception catch (e) {
      throw HttpException('An error occurred: $e');
    }
  }

  Future<List<QuestionModel>> fetchQuestions(int categoryId) async {
    final urlString = '${AppConstants.baseUrl}/categories/$categoryId/questions';
    final url = Uri.parse(urlString);
    
    if (kDebugMode) {
      debugPrint('ApiService: Fetching questions...');
      debugPrint('Category ID: $categoryId');
      debugPrint('Request URL: $url');
    }
    
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 15));
      if (kDebugMode) debugPrint('Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final dynamic dataField = decodedData['data'];
        
        if (dataField is List) {
          final List<QuestionModel> questions = dataField
              .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
              .toList();
          
          if (kDebugMode) debugPrint('Questions Count: ${questions.length}');
          return questions;
        } else {
          return [];
        }
      } else {
        throw HttpException('Server Error: ${response.statusCode}');
      }
    } on SocketException {
      throw const HttpException('No Internet connection');
    } on Exception catch (e) {
      throw HttpException('Error: $e');
    }
  }
}

class HttpException implements Exception {
  final String message;
  const HttpException(this.message);

  @override
  String toString() => message;
}
