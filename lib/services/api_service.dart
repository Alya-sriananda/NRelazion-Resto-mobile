import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan URL Web App Google Apps Script Anda setelah deploy
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbx_8xnqpmcW2EKxscIeTiFwyRZNWRRZD5wjrAone8U9cJsMvagpL7srja4pgD4q4VV6cg/exec';

  // GET requests
  Future<Map<String, dynamic>> get(String action, {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'action': action,
        ...?params,
      });
      final response = await http.get(uri);
      
      if (response.statusCode == 200 || response.statusCode == 302) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'HTTP Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

  // POST requests
  Future<Map<String, dynamic>> post(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        // Use text/plain or drop headers to avoid CORS preflight (OPTIONS) on Flutter Web
        // headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode == 200 || response.statusCode == 302) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'HTTP Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Exception: $e'};
    }
  }
}
