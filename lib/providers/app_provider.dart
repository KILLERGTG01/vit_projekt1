import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_handler/share_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../api/api_service.dart';
import '../models/misinformation_response.dart';
import '../models/threat_analysis_response.dart';
import '../models/phishing_detection_response.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  File? _pickedImage;
  String _inputText = "";
  bool _isLoading = false;
  MisinformationResponse? _apiResponse;
  String? _apiError;
  
  // Threat analysis properties
  bool _isThreatAnalysisLoading = false;
  ThreatAnalysisResponse? _threatAnalysisResponse;
  String? _threatAnalysisError;
  
  // Phishing detection properties
  bool _isPhishingDetectionLoading = false;
  PhishingDetectionResponse? _phishingDetectionResponse;
  String? _phishingDetectionError;
  
  // Sharing intent streams
  late StreamSubscription _intentDataStreamSubscription;
  
  // Track if content was actually shared from another app
  bool _hasSharedContent = false;

  void initializeSharedContent() {
    _logger.d('Initializing sharing intent handlers');
    
    // Listen for shared media files (images)
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        _logger.d('Received ${value.length} shared media files');
        if (value.isNotEmpty) {
          _handleSharedMediaFiles(value);
        }
      },
      onError: (err) {
        _logger.e('Error in media stream: $err');
      },
    );



    // Get initial shared media (when app is opened from share)
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      _logger.d('Initial shared media files: ${value.length}');
      if (value.isNotEmpty) {
        _handleSharedMediaFiles(value);
      }
    }).catchError((err) {
      _logger.e('Error getting initial media: $err');
    });


    
    // Fallback: Also initialize share_handler for additional compatibility
    _initializeShareHandlerFallback();
  }

  void _initializeShareHandlerFallback() {
    ShareHandler.instance.sharedMediaStream.listen((SharedMedia media) {
      _logger.d('ShareHandler fallback received: ${media.content}');
      // Only use as fallback if we haven't received anything from ReceiveSharingIntent
      if (_pickedImage == null && _inputText.isEmpty && media.content != null) {
        _handleSharedMedia(media);
      }
    });

    ShareHandler.instance.getInitialSharedMedia().then((SharedMedia? media) {
      _logger.d('ShareHandler fallback initial: ${media?.content}');
      if (media != null && _pickedImage == null && _inputText.isEmpty) {
        _handleSharedMedia(media);
      }
    });
  }

  Future<void> _handleSharedMediaFiles(List<SharedMediaFile> mediaFiles) async {
    for (SharedMediaFile mediaFile in mediaFiles) {
      _logger.d('Processing media file: ${mediaFile.path}, type: ${mediaFile.type}');
      
      if (mediaFile.type == SharedMediaType.image) {
        try {
          File sourceFile = File(mediaFile.path);
          if (await sourceFile.exists()) {
            // Copy to app directory for persistence
            final Directory appDir = await getApplicationDocumentsDirectory();
            final String fileName = 'shared_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final File targetFile = File('${appDir.path}/$fileName');
            
            await sourceFile.copy(targetFile.path);
            _pickedImage = targetFile;
            _hasSharedContent = true; // Mark as shared content
            _logger.d('Successfully set shared image: ${targetFile.path}');
            notifyListeners();
            break; // Only process the first image
          } else {
            _logger.w('Shared image file does not exist: ${mediaFile.path}');
          }
        } catch (e) {
          _logger.e('Error processing shared image: $e');
        }
      }
    }
  }



  Future<void> _handleSharedMedia(SharedMedia media) async {
    if (media.content != null && media.content!.isNotEmpty) {
      // Handle text content (check if content looks like text)
      if (!media.content!.startsWith('/') && !media.content!.contains('content://')) {
        _setSharedText(media.content!);
        return;
      }
      
      // Fallback: try to determine type from content
      if (media.content!.startsWith('/') || media.content!.contains('content://')) {
        try {
          File? imageFile = await _processSharedImage(media.content!);
          if (imageFile != null) {
            _pickedImage = imageFile;
            _hasSharedContent = true; // Mark as shared content
            _logger.d('Set shared image (fallback): ${imageFile.path}');
            notifyListeners();
          }
        } catch (e) {
          _logger.e('Error processing shared image (fallback): $e');
          // If image processing fails, treat as text
          _setSharedText(media.content!);
        }
      } else {
        // Treat as text
        _setSharedText(media.content!);
      }
    }
  }

  Future<File?> _processSharedImage(String imagePath) async {
    try {
      File sourceFile = File(imagePath);
      
      // Check if it's a content URI (Android)
      if (imagePath.startsWith('content://')) {
        // Use platform channel to copy content URI to app directory
        return await _copyContentUriToFile(imagePath);
      }
      
      // Check if file exists and is readable
      if (await sourceFile.exists()) {
        // Copy to app directory to ensure we have access
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'shared_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File targetFile = File('${appDir.path}/$fileName');
        
        await sourceFile.copy(targetFile.path);
        return targetFile;
      }
      
      return null;
    } catch (e) {
      _logger.e('Error processing shared image: $e');
      return null;
    }
  }

  Future<File?> _copyContentUriToFile(String contentUri) async {
    try {
      const platform = MethodChannel('com.example.project_1/file_utils');
      final Uint8List? imageBytes = await platform.invokeMethod('getImageFromUri', {'uri': contentUri});
      
      if (imageBytes != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'shared_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File targetFile = File('${appDir.path}/$fileName');
        
        await targetFile.writeAsBytes(imageBytes);
        return targetFile;
      }
      
      return null;
    } catch (e) {
      _logger.e('Error copying content URI: $e');
      return null;
    }
  }

  File? get pickedImage => _pickedImage;
  String get inputText => _inputText;
  bool get isLoading => _isLoading;
  MisinformationResponse? get apiResponse => _apiResponse;
  String? get apiError => _apiError;
  
  bool get isThreatAnalysisLoading => _isThreatAnalysisLoading;
  ThreatAnalysisResponse? get threatAnalysisResponse => _threatAnalysisResponse;
  String? get threatAnalysisError => _threatAnalysisError;
  
  bool get isPhishingDetectionLoading => _isPhishingDetectionLoading;
  PhishingDetectionResponse? get phishingDetectionResponse => _phishingDetectionResponse;
  String? get phishingDetectionError => _phishingDetectionError;
  
  // Check if content was actually shared from another app
  bool get hasSharedContent => _hasSharedContent;

  void setInputText(String text) {
    _inputText = text;
    // Don't automatically reset shared flag here, as this method is called
    // both for manual input and when setting shared text
    notifyListeners();
  }
  
  // Method specifically for manual text input (called from UI)
  void setManualInputText(String text) {
    _inputText = text;
    // This is manual input, not shared content
    _hasSharedContent = false;
    notifyListeners();
  }
  
  // Helper method to set shared text content
  void _setSharedText(String text) {
    _inputText = text;
    _hasSharedContent = true; // Mark as shared content
    _logger.d('Set shared text: $_inputText');
    notifyListeners();
  }
  
  void clearInputs() {
    _pickedImage = null;
    _inputText = "";
    _apiResponse = null;
    _apiError = null;
    _threatAnalysisResponse = null;
    _threatAnalysisError = null;
    _phishingDetectionResponse = null;
    _phishingDetectionError = null;
    _hasSharedContent = false; // Reset shared content flag
    
    // Reset sharing intent to clear any cached shared content
    ReceiveSharingIntent.instance.reset();
    
    notifyListeners();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _pickedImage = File(image.path);
      // This is manually picked, not shared content
      // Don't change _hasSharedContent flag here
      notifyListeners();
    }
  }

  Future<void> submitData(BuildContext context) async {
    // Validate that we have at least one valid field
    final hasValidText = _inputText.trim().isNotEmpty;
    final hasValidImage = _pickedImage != null;
    
    if (!hasValidText && !hasValidImage) {
      _logger.w('⚠️ No valid data to submit - both text and image are empty');
      return;
    }
    
    _logger.i('🔍 MISINFORMATION CHECK - Initiated by user');
    _logger.i('   Text content: ${hasValidText ? '"${_inputText.trim()}"' : 'None (empty/whitespace)'}');
    _logger.i('   Image file: ${hasValidImage ? _pickedImage!.path : 'None'}');
    
    _isLoading = true;
    _apiResponse = null;
    _apiError = null;
    notifyListeners();
    if (context.mounted) {
      Navigator.pushNamed(context, '/response');
    }

    try {
      _logger.i('📡 Calling API service...');
      final textToSend = hasValidText ? _inputText.trim() : null;
      final response = await _apiService.sendData(text: textToSend, imageFile: _pickedImage);
      _logger.i('✅ API response received, parsing JSON...');
      _logger.i('Raw response: ${response.substring(0, response.length > 200 ? 200 : response.length)}...');
      
      // Parse the JSON response
      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response);
        _logger.i('✅ JSON parsing successful');
      } catch (formatException) {
        _logger.e('❌ JSON parsing failed: $formatException');
        _logger.i('Raw response causing error: $response');
        throw Exception('Failed to parse server response: ${formatException.toString()}');
      }
      
      _apiResponse = MisinformationResponse.fromJson(jsonResponse);
      _logger.i('🎯 Misinformation analysis completed successfully');
    } catch (e) {
      _logger.e('❌ Misinformation analysis failed: $e');
      
      // Provide user-friendly error messages
      if (e.toString().contains('Server validation error')) {
        _apiError = "The server is experiencing a technical issue with response formatting. Please try again later or contact support.";
      } else if (e.toString().contains('500')) {
        _apiError = "Server error occurred. The request was sent correctly but the server encountered an issue processing it.";
      } else {
        _apiError = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeThreat(BuildContext context, String content) async {
    // Validate content is not empty or just whitespace
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      _logger.w('⚠️ No valid content to analyze - content is empty or whitespace only');
      return;
    }
    
    _logger.i('🛡️ THREAT ANALYSIS - Initiated by user');
    _logger.i('   Content to analyze: "$trimmedContent"');
    _logger.i('   Content length: ${trimmedContent.length} characters');
    
    _isThreatAnalysisLoading = true;
    _threatAnalysisResponse = null;
    _threatAnalysisError = null;
    notifyListeners();
    
    if (context.mounted) {
      Navigator.pushNamed(context, '/threat-analysis');
    }

    try {
      _logger.i('📡 Calling threat analysis API service...');
      final response = await _apiService.analyzeThreat(content: trimmedContent);
      _logger.i('✅ Threat analysis API response received, parsing JSON...');
      final jsonResponse = jsonDecode(response);
      _threatAnalysisResponse = ThreatAnalysisResponse.fromJson(jsonResponse);
      _logger.i('🎯 Threat analysis completed successfully');
    } catch (e) {
      _logger.e('❌ Threat analysis failed: $e');
      _threatAnalysisError = e.toString();
    } finally {
      _isThreatAnalysisLoading = false;
      notifyListeners();
    } 
  }

  Future<void> detectPhishing(BuildContext context, String content, {String? contentType, Map<String, dynamic>? senderInfo}) async {
    // Validate content is not empty or just whitespace
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      _logger.w('⚠️ No valid content to analyze - content is empty or whitespace only');
      return;
    }
    
    _logger.i('🎣 PHISHING DETECTION - Initiated by user');
    _logger.i('   Content to analyze: "$trimmedContent"');
    _logger.i('   Content length: ${trimmedContent.length} characters');
    _logger.i('   Content type: ${contentType ?? 'default'}');
    _logger.i('   Sender info: ${senderInfo != null ? 'provided' : 'none'}');
    
    _isPhishingDetectionLoading = true;
    _phishingDetectionResponse = null;
    _phishingDetectionError = null;
    notifyListeners();
    
    if (context.mounted) {
      Navigator.pushNamed(context, '/phishing-detection');
    }

    try {
      _logger.i('📡 Calling phishing detection API service...');
      final response = await _apiService.detectPhishing(
        content: trimmedContent,
        contentType: contentType,
        senderInfo: senderInfo,
      );
      _logger.i('✅ Phishing detection API response received, parsing JSON...');
      final jsonResponse = jsonDecode(response);
      _phishingDetectionResponse = PhishingDetectionResponse.fromJson(jsonResponse);
      _logger.i('🎯 Phishing detection completed successfully');
    } catch (e) {
      _logger.e('❌ Phishing detection failed: $e');
      _phishingDetectionError = e.toString();
    } finally {
      _isPhishingDetectionLoading = false;
      notifyListeners();
    } 
  }


}