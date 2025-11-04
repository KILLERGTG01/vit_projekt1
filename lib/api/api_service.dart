import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String _baseUrl =
      "https://api.abhinavganeshan.in/api/misinformation/check";
  static const String _threatAnalysisUrl =
      "https://api.abhinavganeshan.in/api/message-threat/analyze";
  final Logger _logger = Logger();

  /// Generates a curl command equivalent for debugging purposes
  String _generateCurlCommand(String url, Map<String, String> headers, {String? body, String? formData}) {
    final buffer = StringBuffer();
    buffer.write('curl -X POST ');
    
    // Add headers
    headers.forEach((key, value) {
      buffer.write('-H "$key: $value" ');
    });
    
    // Add body or form data
    if (body != null) {
      buffer.write('--data "$body" ');
    } else if (formData != null) {
      buffer.write('--data "$formData" ');
    }
    
    buffer.write('"$url"');
    return buffer.toString();
  }

  Future<String> sendData({String? text, File? imageFile}) async {
    if ((text == null || text.isEmpty) && imageFile == null) {
      throw Exception("No data to send.");
    }

    try {
      _logger.i('🚀 MISINFORMATION CHECK - Starting API Request');
      _logger.i('📍 Endpoint: $_baseUrl');
      _logger.i('🔧 Method: POST (multipart/form-data)');
      
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Add text field if provided
      if (text != null && text.isNotEmpty) {
        _logger.i('📝 Adding text field:');
        _logger.i('   Field name: "text"');
        _logger.i('   Content: "$text"');
        _logger.i('   Length: ${text.length} characters');
        request.fields['text'] = text;
      } else {
        _logger.i('📝 No text content provided');
      }

      // Add image file if provided
      if (imageFile != null) {
        final allowedExtensions = ['jpg', 'png', 'webp'];
        String ext = imageFile.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(ext)) {
          throw Exception(
            "Invalid image format. Only PNG, JPG, and WEBP are allowed.",
          );
        }
        
        final fileExists = await imageFile.exists();
        final fileSize = fileExists ? await imageFile.length() : 0;
        
        _logger.i('🖼️ Adding image file:');
        _logger.i('   Field name: "image"');
        _logger.i('   File path: ${imageFile.path}');
        _logger.i('   File extension: $ext');
        _logger.i('   File exists: $fileExists');
        _logger.i('   File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

        MediaType mediaType;
        if (ext == 'png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == 'webp') {
          mediaType = MediaType('image', 'webp');
        } else {
          mediaType = MediaType('image', 'jpeg');
        }
        
        _logger.i('   Content-Type: ${mediaType.mimeType}');
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      } else {
        _logger.i('🖼️ No image file provided');
      }

      // Log complete payload summary
      _logger.i('📦 PAYLOAD SUMMARY:');
      _logger.i('   Text fields: ${request.fields.keys.toList()}');
      _logger.i('   File fields: ${request.files.map((f) => '${f.field} (${f.filename})').toList()}');
      _logger.i('   Total fields: ${request.fields.length + request.files.length}');
      
      // Log headers
      _logger.i('📋 Request Headers:');
      request.headers.forEach((key, value) {
        _logger.i('   $key: $value');
      });

      _logger.i('⏳ Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.i('✅ Response received:');
      _logger.i('   Status Code: ${response.statusCode}');
      _logger.i('   Response Headers: ${response.headers}');
      _logger.i('   Response Body Length: ${response.body.length} characters');
      _logger.i('   Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _logger.i('🎉 MISINFORMATION CHECK - Request successful!');
        return response.body;
      } else {
        _logger.e('❌ MISINFORMATION CHECK - Request failed!');
        _logger.e('   Status: ${response.statusCode}');
        _logger.e('   Body: ${response.body}');
        throw Exception("Failed to send data. Status: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e('💥 MISINFORMATION CHECK - Exception occurred: $e');
      throw Exception("An error occurred: $e");
    }
  }

  Future<String> analyzeThreat({
    required String content,
    String messageType = 'sms',
  }) async {
    if (content.isEmpty) {
      throw Exception("No content to analyze.");
    }

    try {
      _logger.i('🛡️ THREAT ANALYSIS - Starting API Request');
      _logger.i('📍 Endpoint: $_threatAnalysisUrl');
      _logger.i('🔧 Method: POST (application/x-www-form-urlencoded)');
      
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      final body = {'content': content, 'message_type': messageType};
      
      _logger.i('📋 Request Headers:');
      headers.forEach((key, value) {
        _logger.i('   $key: $value');
      });
      
      _logger.i('📦 PAYLOAD DETAILS:');
      _logger.i('   Field: "content"');
      _logger.i('   Content: "$content"');
      _logger.i('   Content Length: ${content.length} characters');
      _logger.i('   Field: "message_type"');
      _logger.i('   Message Type: "$messageType"');
      
      _logger.i('📝 Raw Form Data:');
      final formData = body.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      _logger.i('   $formData');
      _logger.i('   Form Data Length: ${formData.length} characters');
      
      _logger.i('🔧 Equivalent curl command:');
      _logger.i('   ${_generateCurlCommand(_threatAnalysisUrl, headers, formData: formData)}');

      _logger.i('⏳ Sending request...');
      final response = await http.post(
        Uri.parse(_threatAnalysisUrl),
        headers: headers,
        body: body,
      );

      _logger.i('✅ Response received:');
      _logger.i('   Status Code: ${response.statusCode}');
      _logger.i('   Response Headers: ${response.headers}');
      _logger.i('   Response Body Length: ${response.body.length} characters');
      _logger.i('   Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _logger.i('🎉 THREAT ANALYSIS - Request successful!');
        return response.body;
      } else {
        _logger.e('❌ THREAT ANALYSIS - Request failed!');
        _logger.e('   Status: ${response.statusCode}');
        _logger.e('   Body: ${response.body}');
        throw Exception(
          "Failed to analyze threat. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _logger.e('💥 THREAT ANALYSIS - Exception occurred: $e');
      throw Exception("An error occurred during threat analysis: $e");
    }
  }
}
