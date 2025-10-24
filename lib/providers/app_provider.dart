import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';
import '../models/misinformation_response.dart';
import '../models/threat_analysis_response.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;
  String _inputText = "";
  bool _isLoading = false;
  MisinformationResponse? _apiResponse;
  String? _apiError;
  
  // Threat analysis properties
  bool _isThreatAnalysisLoading = false;
  ThreatAnalysisResponse? _threatAnalysisResponse;
  String? _threatAnalysisError;

  File? get pickedImage => _pickedImage;
  String get inputText => _inputText;
  bool get isLoading => _isLoading;
  MisinformationResponse? get apiResponse => _apiResponse;
  String? get apiError => _apiError;
  
  bool get isThreatAnalysisLoading => _isThreatAnalysisLoading;
  ThreatAnalysisResponse? get threatAnalysisResponse => _threatAnalysisResponse;
  String? get threatAnalysisError => _threatAnalysisError;

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }
  
  void clearInputs() {
    _pickedImage = null;
    _inputText = "";
    _apiResponse = null;
    _apiError = null;
    _threatAnalysisResponse = null;
    _threatAnalysisError = null;
    notifyListeners();
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _pickedImage = File(image.path);
      notifyListeners();
    }
  }

  Future<void> submitData(BuildContext context) async {
    if (_inputText.isEmpty && _pickedImage == null) return;
    _isLoading = true;
    _apiResponse = null;
    _apiError = null;
    notifyListeners();
    Navigator.pushNamed(context, '/response');

    try {
      final response = await _apiService.sendData(text: _inputText, imageFile: _pickedImage);
      final jsonResponse = jsonDecode(response);
      _apiResponse = MisinformationResponse.fromJson(jsonResponse);
    } catch (e) {
      _apiError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeThreat(BuildContext context, String content) async {
    if (content.isEmpty) return;
    
    _isThreatAnalysisLoading = true;
    _threatAnalysisResponse = null;
    _threatAnalysisError = null;
    notifyListeners();
    
    Navigator.pushNamed(context, '/threat-analysis');

    try {
      final response = await _apiService.analyzeThreat(content: content);
      final jsonResponse = jsonDecode(response);
      _threatAnalysisResponse = ThreatAnalysisResponse.fromJson(jsonResponse);
    } catch (e) {
      _threatAnalysisError = e.toString();
    } finally {
      _isThreatAnalysisLoading = false;
      notifyListeners();
    }
  }
}