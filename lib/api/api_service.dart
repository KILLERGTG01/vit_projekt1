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

  Future<String> sendData({String? text, File? imageFile}) async {
    if ((text == null || text.isEmpty) && imageFile == null) {
      throw Exception("No data to send.");
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      if (text != null && text.isNotEmpty) {
        _logger.d('Sending text: $text');
        request.fields['text'] = text;
      }

      if (imageFile != null) {
        final allowedExtensions = ['jpg', 'png', 'webp'];
        String ext = imageFile.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(ext)) {
          throw Exception(
            "Invalid image format. Only PNG, JPG, and WEBP are allowed.",
          );
        }
        _logger.d('Uploading file: ${imageFile.path}');
        _logger.d('File exists: ${await imageFile.exists()}');
        _logger.d('File length: ${await imageFile.length()}');

        MediaType mediaType;
        if (ext == 'png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == 'webp') {
          mediaType = MediaType('image', 'webp');
        } else {
          mediaType = MediaType('image', 'jpeg');
        }
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      _logger.d('Request fields: ${request.fields}');
      _logger.d('Request files: ${request.files.map((f) => f.filename)}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.d('Status code: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception("Failed to send data. Status: ${response.statusCode}");
      }
    } catch (e) {
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
      _logger.d('Analyzing threat for content: $content');

      final response = await http.post(
        Uri.parse(_threatAnalysisUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'content': content, 'message_type': messageType},
      );

      _logger.d('Threat analysis status code: ${response.statusCode}');
      _logger.d('Threat analysis response body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
          "Failed to analyze threat. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("An error occurred during threat analysis: $e");
    }
  }
}
