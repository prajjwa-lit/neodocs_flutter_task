import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../models/range_section.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ApiService {
  final String url;
  final String bearerToken;
  final int maxRetries;
  final Duration initialRetryDelay;

  ApiService({
    required this.url,
    required this.bearerToken,
    this.maxRetries = 3,
    this.initialRetryDelay = const Duration(seconds: 1),
  });

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<List<RangeSection>> fetchRanges() async {
    if (!await checkConnectivity()) {
      throw ApiException('No internet connection available');
    }

    int retryCount = 0;
    Duration currentDelay = initialRetryDelay;

    while (true) {
      final client = HttpClient();
      try {
        final uri = Uri.parse(url);
        final request = await client.getUrl(uri);
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        
        final response = await request.close().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw ApiException('Request timed out');
          },
        );
        
        final body = await response.transform(utf8.decoder).join();

        if (response.statusCode == 200) {
          try {
            final decoded = jsonDecode(body);
            if (decoded is List) {
              return decoded
                  .map<RangeSection>((e) => RangeSection.fromJson(Map<String, dynamic>.from(e)))
                  .toList();
            } else if (decoded is Map && decoded.containsKey('ranges')) {
              final list = decoded['ranges'];
              if (list is List) {
                return list
                    .map<RangeSection>((e) => RangeSection.fromJson(Map<String, dynamic>.from(e)))
                    .toList();
              }
            }
            throw ApiException('Unexpected JSON format from server', data: decoded);
          } catch (e) {
            if (e is ApiException) rethrow;
            throw ApiException('Failed to parse server response', data: body);
          }
        } else if (response.statusCode >= 500) {
          throw ApiException(
            'Server error occurred',
            statusCode: response.statusCode,
            data: body,
          );
        } else {
          throw ApiException(
            _getErrorMessage(response.statusCode, body),
            statusCode: response.statusCode,
            data: body,
          );
        }
      } catch (e) {
        final isRetryable = _isRetryableError(e);
        
        if (isRetryable && retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(currentDelay);
          currentDelay *= 2;
          continue;
        }
        
        if (e is ApiException) {
          rethrow;
        }
        throw ApiException(e.toString());
      } finally {
        client.close();
      }
    }
  }

  bool _isRetryableError(dynamic error) {
    return error is SocketException ||
           error is TimeoutException ||
           (error is ApiException && error.statusCode != null && error.statusCode! >= 500);
  }

  String _getErrorMessage(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized: Please check your authentication token';
      case 403:
        return 'Forbidden: You don\'t have permission to access this resource';
      case 404:
        return 'Resource not found';
      case 429:
        return 'Too many requests: Please try again later';
      default:
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map && decoded.containsKey('message')) {
            return decoded['message'];
          }
        } catch (_) {}
        return 'HTTP Error $statusCode';
    }
  }
}