// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import '../models/range_section.dart';

class ApiService {
  final String url;
  final String bearerToken;

  ApiService({required this.url, required this.bearerToken});

  /// Fetch list of RangeSections.
  /// Uses dart:io HttpClient (no external http package).
  Future<List<RangeSection>> fetchRanges() async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        if (decoded is List) {
          return decoded
              .map<RangeSection>((e) => RangeSection.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else if (decoded is Map && decoded.containsKey('ranges')) {
          // defensive: some APIs wrap the array
          final list = decoded['ranges'];
          if (list is List) {
            return list
                .map<RangeSection>((e) => RangeSection.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
        throw Exception('Unexpected JSON format from server');
      } else {
        throw Exception('HTTP ${response.statusCode}: $body');
      }
    } finally {
      client.close();
    }
  }
}
