import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = "https://prj-1.abhinavganeshan.in/check-misinformation";

  Future<String> sendData({String? text, File? imageFile}) async {
    if (text == null && imageFile == null) {
      throw Exception("No data to send.");
    }

    try {
      if (imageFile != null) {
        var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        if (text != null && text.isNotEmpty) {
          request.fields['text'] = text;
        }
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          return json.decode(response.body)['message'];
        } else {
          throw Exception("Failed to upload. Status: ${response.statusCode}");
        }
      } else {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'text': text}),
        );
        
        if (response.statusCode == 200) {
          return json.decode(response.body)['message'];
        } else {
          throw Exception("Failed to send text. Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }
}