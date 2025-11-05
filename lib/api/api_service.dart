import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String _baseUrl = "https://api.abhinavganeshan.in/api/misinformation/check";
  static const String _threatAnalysisUrl = "https://api.abhinavganeshan.in/api/message-threat/analyze";
  
  final Logger _logger = Logger();
  late final Dio _dio;

  ApiService() {
    _dio = Dio();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.connectTimeout = const Duration(minutes: 5);
    _dio.options.receiveTimeout = const Duration(minutes: 5);
    _dio.options.followRedirects = true; // This matches curl --location
    _dio.options.maxRedirects = 5;
    _dio.options.headers = {
      'Accept': '*/*',
      'User-Agent': 'curl/7.68.0', // Match curl user agent
    };
  }

  /// Validates input data and throws appropriate exceptions
  void _validateInputs({String? text, File? imageFile}) {
    final hasValidText = text != null && text.trim().isNotEmpty;
    final hasValidImage = imageFile != null;
    
    if (!hasValidText && !hasValidImage) {
      throw Exception("No valid data to send. Both text and image are empty or null.");
    }
  }

  /// Validates image file and returns processed data
  Future<Map<String, dynamic>> _validateAndProcessImage(File imageFile) async {
    _logger.i('🔍 Validating image file: ${imageFile.path}');
    
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    final ext = imageFile.path.split('.').last.toLowerCase();
    
    _logger.i('   Extension: $ext');
    
    if (!allowedExtensions.contains(ext)) {
      throw Exception("Invalid image format '$ext'. Only PNG, JPG, JPEG, and WEBP are allowed.");
    }
    
    final fileExists = await imageFile.exists();
    _logger.i('   File exists: $fileExists');
    
    if (!fileExists) {
      throw Exception("Image file does not exist: ${imageFile.path}");
    }
    
    final fileSize = await imageFile.length();
    _logger.i('   File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
    
    if (fileSize == 0) {
      throw Exception("Image file is empty: ${imageFile.path}");
    }
    
    // Check if file is too large (e.g., > 10MB)
    if (fileSize > 10 * 1024 * 1024) {
      _logger.w('⚠️ Large file detected: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    }
    
    final imageBytes = await imageFile.readAsBytes();
    _logger.i('   Bytes read: ${imageBytes.length}');
    
    if (imageBytes.isEmpty) {
      throw Exception("Image file contains no data");
    }
    
    // Basic format validation
    if (ext == 'png' && imageBytes.length >= 8) {
      final isPng = imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && 
                   imageBytes[2] == 0x4E && imageBytes[3] == 0x47;
      _logger.i('   PNG format check: $isPng');
    } else if ((ext == 'jpg' || ext == 'jpeg') && imageBytes.length >= 2) {
      final isJpeg = imageBytes[0] == 0xFF && imageBytes[1] == 0xD8;
      _logger.i('   JPEG format check: $isJpeg');
    }
    
    // Determine content type
    String contentType;
    switch (ext) {
      case 'png':
        contentType = 'image/png';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
      case 'jpg':
      case 'jpeg':
      default:
        contentType = 'image/jpeg';
        break;
    }
    
    _logger.i('   Content-Type: $contentType');
    
    return {
      'bytes': imageBytes,
      'filename': imageFile.path.split('/').last,
      'contentType': contentType,
      'size': fileSize,
    };
  }


  /// Test method that exactly replicates your working curl commands
  Future<String> testCurlReplication() async {
    _logger.i('🧪 TESTING EXACT CURL REPLICATION');
    
    try {
      // Test 1: curl --location --form 'text="grok is smarter than gemini"'
      _logger.i('📝 Test 1: Text-only request');
      final formData1 = FormData();
      formData1.fields.add(const MapEntry('text', 'grok is smarter than gemini'));
      
      final response1 = await _dio.post(
        _baseUrl,
        data: formData1,
        options: Options(
          headers: {
            'Accept': '*/*',
            'User-Agent': 'curl/7.68.0',
          },
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
      
      _logger.i('✅ Test 1 SUCCESS: Status ${response1.statusCode}');
      
      return response1.data.toString();
    } catch (e) {
      _logger.e('❌ Curl replication test failed: $e');
      if (e is DioException) {
        _logger.e('   Status: ${e.response?.statusCode}');
        _logger.e('   Response: ${e.response?.data}');
        _logger.e('   Headers: ${e.response?.headers.map}');
      }
      rethrow;
    }
  }

  /// Main method for sending data - exactly matches curl --location --form format
  Future<String> sendData({String? text, File? imageFile}) async {
    _validateInputs(text: text, imageFile: imageFile);

    try {
      // Create FormData exactly like curl --form
      final formData = FormData();
      
      // Add text field if provided (curl --form 'text="value"')
      if (text != null && text.trim().isNotEmpty) {
        final trimmedText = text.trim();
        formData.fields.add(MapEntry('text', trimmedText));
        _logger.i('✅ Added text field: "$trimmedText"');
      }
      
      if (imageFile != null) {
        final imageData = await _validateAndProcessImage(imageFile);
        
        // Create MultipartFile exactly like curl does
        final multipartFile = MultipartFile.fromBytes(
          imageData['bytes'],
          filename: imageData['filename'],
          contentType: MediaType.parse(imageData['contentType']),
        );
        
        formData.files.add(MapEntry('image', multipartFile));
      }
      
      
      // Send request with explicit options to match curl behavior
      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Accept': '*/*',
            'User-Agent': 'curl/7.68.0',
          },
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 500, // Accept redirects
        ),
      );
      
      if (response.statusCode == 200) {
        // Check if response.data is already a Map (parsed JSON) or a String
        if (response.data is Map) {
          _logger.i('📄 Response is already parsed as Map');
          return jsonEncode(response.data); // Convert Map back to JSON string
        } else {
          _logger.i('📄 Response is raw string');
          return response.data.toString();
        }
      } else if (response.statusCode == 500) {
        // Handle server-side validation errors
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('detail')) {
          final detail = responseData['detail'].toString();
          if (detail.contains('validation error') && detail.contains('verdict')) {
            _logger.w('⚠️ Server-side validation error detected - this is a backend issue');
            _logger.w('   The server returned an invalid verdict format');
            throw Exception("Server validation error: The backend returned an invalid response format. This is a server-side issue that needs to be fixed.");
          }
        }
        _logger.e('❌ Server error (500): ${response.data}');
        throw Exception("Server error (500): ${response.data}");
      } else {
        _logger.e('❌ Non-200 status: ${response.statusCode}');
        _logger.e('   Response body: ${response.data}');
        throw Exception("Request failed with status: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      _logger.e('❌ Request failed: $e');
      if (e is DioException) {
        _logger.e('   Type: ${e.type}');
        _logger.e('   Message: ${e.message}');
        _logger.e('   Request URL: ${e.requestOptions.uri}');
        _logger.e('   Request headers: ${e.requestOptions.headers}');
        _logger.e('   Response status: ${e.response?.statusCode}');
        _logger.e('   Response headers: ${e.response?.headers.map}');
        _logger.e('   Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Phishing detection method using JSON data
  Future<String> detectPhishing({
    required String content,
    String? contentType,
    Map<String, dynamic>? senderInfo,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw Exception("No valid content to analyze. Content is empty or contains only whitespace.");
    }

    const phishingUrl = "https://api.abhinavganeshan.in/api/phishing/detect-content";
    
    try {
      // Build the JSON payload based on the conditions
      final Map<String, dynamic> payload = {'content': trimmedContent};
      
      // Add content_type if provided (defaults to 'sms' when specified)
      if (contentType != null && contentType.trim().isNotEmpty) {
        payload['content_type'] = contentType.trim();
      }
      
      // Add sender_info if provided (only for email content)
      if (senderInfo != null && senderInfo.isNotEmpty) {
        payload['sender_info'] = senderInfo;
      }

      final response = await _dio.post(
        phishingUrl,
        data: payload,
        options: Options(
          contentType: 'application/json',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('✅ Phishing detection response received:');
      _logger.i('   Status: ${response.statusCode}');
      _logger.i('   Body length: ${response.data.toString().length} chars');

      if (response.statusCode == 200) {
        // Check if response.data is already a Map (parsed JSON) or a String
        if (response.data is Map) {
          return jsonEncode(response.data); // Convert Map back to JSON string
        } else {
          return response.data.toString();
        }
      } else {
        throw Exception("Phishing detection failed with status: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e('❌ Phishing detection failed: $e');
      if (e is DioException) {
        _logger.e('   Type: ${e.type}');
        _logger.e('   Response: ${e.response?.data}');
        _logger.e('   Status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  /// Threat analysis method using form-encoded data
  Future<String> analyzeThreat({
    required String content,
    String messageType = 'sms',
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw Exception("No valid content to analyze. Content is empty or contains only whitespace.");
    }


    try {
      final body = <String, String>{
        'content': trimmedContent,
        if (messageType.trim().isNotEmpty) 'message_type': messageType.trim(),
      };
      
      _logger.i('📡 Sending form-encoded request...');
      final response = await _dio.post(
        _threatAnalysisUrl,
        data: body,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      _logger.i('✅ Response received:');
      _logger.i('   Status: ${response.statusCode}');
      _logger.i('   Body length: ${response.data.toString().length} chars');

      if (response.statusCode == 200) {
        final responseData = response.data.toString();
        _logger.i('   Raw response: ${responseData.substring(0, responseData.length > 200 ? 200 : responseData.length)}...');
        
        // Check if response.data is already a Map (parsed JSON) or a String
        if (response.data is Map) {
          _logger.i('📄 Response is already parsed as Map');
          return jsonEncode(response.data); // Convert Map back to JSON string
        } else {
          _logger.i('📄 Response is raw string, attempting to parse...');
          
          // Try to parse as JSON first
          try {
            final jsonData = jsonDecode(responseData);
            return jsonEncode(jsonData); // Re-encode to ensure proper formatting
          } catch (jsonError) {
            _logger.w('⚠️ JSON parsing failed, checking if it\'s malformed JSON...');
            
            // Check if it looks like malformed JSON (unquoted keys)
            if (responseData.trim().startsWith('{') && responseData.trim().endsWith('}')) {
              _logger.w('⚠️ Detected malformed JSON, attempting to fix...');
              
              try {
                // Try to fix common malformed JSON issues
                String fixedJson = responseData
                    .replaceAllMapped(RegExp(r'(\w+):'), (match) => '"${match.group(1)}":')
                    .replaceAllMapped(RegExp(r':\s*([^",\{\[\]\}]+)(?=[,\}])'), (match) {
                      final value = match.group(1)?.trim();
                      if (value != null && !value.startsWith('"') && !value.startsWith('[') && !value.startsWith('{')) {
                        // Check if it's a number or boolean
                        if (RegExp(r'^-?\d+\.?\d*$').hasMatch(value) || value == 'true' || value == 'false' || value == 'null') {
                          return ': $value';
                        } else {
                          return ': "$value"';
                        }
                      }
                      return match.group(0) ?? '';
                    });
                
                _logger.i('🔧 Fixed JSON: ${fixedJson.substring(0, fixedJson.length > 200 ? 200 : fixedJson.length)}...');
                
                // Try to parse the fixed JSON
                final parsedJson = jsonDecode(fixedJson);
                return jsonEncode(parsedJson);
              } catch (fixError) {
                _logger.e('❌ Failed to fix malformed JSON: $fixError');
                throw Exception('Server returned malformed JSON response. This is a server-side issue that needs to be fixed.');
              }
            } else {
              _logger.e('❌ Response is not JSON format');
              throw Exception('Server returned non-JSON response: ${responseData.substring(0, 100)}...');
            }
          }
        }
      } else {
        throw Exception("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e('❌ Threat analysis failed: $e');
      if (e is DioException) {
        _logger.e('   Type: ${e.type}');
        _logger.e('   Response: ${e.response?.data}');
        _logger.e('   Status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
}
