import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Ganti dengan URL Web App Google Apps Script Anda setelah deploy
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbyycrjT6ABJAvOxWLiHCFOLJlMJxnB4mpaPNNLSKlg0L68hSPwE4RBFxVKFAd82cfysnw/exec';

  // GET requests
  Future<Map<String, dynamic>> get(String action, {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'action': action,
        ...?params,
      });
      final response = await http.get(uri);
      
      // Handle redirects manually
      if (response.statusCode == 302 || response.statusCode == 301) {
        final location = response.headers['location'];
        if (location != null) {
          final redirectResponse = await http.get(Uri.parse(location));
          return json.decode(redirectResponse.body);
        }
      }

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('<')) {
          return {'success': false, 'message': 'Terjadi kesalahan sistem (HTML Response)'};
        }
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
        headers: kIsWeb 
          ? {} // Web: No header to avoid CORS preflight
          : {'Content-Type': 'application/json'}, // Mobile: Proper JSON header
        body: json.encode(data),
      );
      
      // Handle redirects manually for GAS (especially on Mobile)
      if (response.statusCode == 302 || response.statusCode == 301) {
        final location = response.headers['location'];
        if (location != null) {
          final redirectResponse = await http.get(Uri.parse(location));
          return json.decode(redirectResponse.body);
        }
      }

      if (response.statusCode == 200) {
        // Double check if body is HTML (happens if 302 is followed but body is still redirect page)
        if (response.body.trim().startsWith('<')) {
          return {'success': false, 'message': 'Terjadi kesalahan sistem (HTML Response)'};
        }
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'HTTP Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Exception: $e'};
    }
  }
}
