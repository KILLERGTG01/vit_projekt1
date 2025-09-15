import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Clear the text field if an image is picked
        if (provider.pickedImage != null && _textController.text.isNotEmpty) {
          _textController.clear();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('VIT Project'),
            actions: [
              // Show a clear button only if there is something to clear
              if(provider.inputText.isNotEmpty || provider.pickedImage != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    provider.clearInputs();
                    _textController.clear();
                  },
                )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // This widget displays the selected image preview
                  if (provider.pickedImage != null)
                    Container(
                      height: 250,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                          image: FileImage(provider.pickedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Text input field
                  TextField(
                    controller: _textController,
                    onChanged: (text) => provider.setInputText(text),
                    decoration: const InputDecoration(
                      labelText: 'Enter text here',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    // Disable the text field if an image is selected
                    enabled: provider.pickedImage == null,
                  ),
                  const SizedBox(height: 20),
                  
                  // The button to pick an image from the gallery
                  ElevatedButton.icon(
                    onPressed: provider.pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick an Image from Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Submit button
                  FilledButton(
                    onPressed: (provider.inputText.isNotEmpty || provider.pickedImage != null)
                        ? () => provider.submitData(context)
                        : null, // Button is disabled if there's no input
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)
                    ),
                    child: const Text('SUBMIT'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}