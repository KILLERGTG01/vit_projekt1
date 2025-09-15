import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
 import 'package:http_parser/http_parser.dart';
class ApiService {
  static const String _baseUrl = "https://prj-1.abhinavganeshan.in/check-misinformation";
  final Logger _logger = Logger();

  Future<String> sendData({String? text, File? imageFile}) async {
    if (text == null && imageFile == null) {
      throw Exception("No data to send.");
    }

    try {
      if (imageFile != null) {
        final allowedExtensions = ['jpg', 'png', 'webp'];
        String ext = imageFile.path.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(ext)) {
          throw Exception("Invalid image format. Only PNG, JPG, and WEBP are allowed.");
        }
        _logger.d('Uploading file: ${imageFile.path}');
        _logger.d('File exists: ${await imageFile.exists()}');
        _logger.d('File length: ${await imageFile.length()}');
        var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        if (text != null && text.isNotEmpty) {
          _logger.d('Sending text: $text');
          request.fields['text'] = text;
        }
         
        MediaType mediaType;
        if (ext == 'png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == 'webp') {
          mediaType = MediaType('image', 'webp');
        } else {
          mediaType = MediaType('image', 'jpeg');
        }
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path, contentType: mediaType));
        _logger.d('Request fields: ${request.fields}');
        _logger.d('Request files: ${request.files.map((f) => f.filename)}');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        _logger.d('Status code: ${response.statusCode}');
        _logger.d('Response body: ${response.body}');

        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("Failed to upload. Status: ${response.statusCode}");
        }
      } else {
        // Use multipart/form-data for text-only requests as well
        var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        if (text != null && text.isNotEmpty) {
          request.fields['text'] = text;
        }
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        _logger.d('Response body: \\${response.body}');

            if (response.statusCode == 200) {
              return response.body;
        } else {
          throw Exception("Failed to send text. Status: \\${response.statusCode}");
        }
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }
}