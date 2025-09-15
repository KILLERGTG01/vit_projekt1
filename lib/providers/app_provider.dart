import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;
  String _inputText = "";
  bool _isLoading = false;
  String? _apiResponse;
  String? _apiError;

  File? get pickedImage => _pickedImage;
  String get inputText => _inputText;
  bool get isLoading => _isLoading;
  String? get apiResponse => _apiResponse;
  String? get apiError => _apiError;

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }
  
  void setSharedImage(File image) {
    _pickedImage = image;
    _inputText = "";
    notifyListeners();
  }

  void clearInputs() {
    _pickedImage = null;
    _inputText = "";
    _apiResponse = null;
    _apiError = null;
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
      _apiResponse = response;
    } catch (e) {
      _apiError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}