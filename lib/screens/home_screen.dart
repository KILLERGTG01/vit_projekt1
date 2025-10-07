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
        // Remove the logic that clears text when image is picked
        // if (provider.pickedImage != null && _textController.text.isNotEmpty) {
        //   _textController.clear();
        // }

        // Keep the text field in sync with provider.inputText
        if (_textController.text != provider.inputText) {
          _textController.text = provider.inputText;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF181C23),
          appBar: AppBar(
            backgroundColor: const Color(0xFF232733),
            title: Row(
              children: [
                const Icon(Icons.shield, color: Colors.blueAccent, size: 30),
                const SizedBox(width: 10),
                Text(
                  'CyberSec Analyzer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
            actions: [
              if (provider.inputText.isNotEmpty || provider.pickedImage != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    provider.clearInputs();
                    _textController.clear();
                  },
                )
            ],
            elevation: 4,
          ),
          body: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Analyze text or images for misinformation and threats.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (provider.pickedImage != null)
                    Container(
                      height: 220,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        image: DecorationImage(
                          image: FileImage(provider.pickedImage!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: _textController,
                    onChanged: (text) => provider.setInputText(text),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter text here',
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      filled: true,
                      fillColor: const Color(0xFF232733),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 2),
                      ),
                    ),
                    // Allow text input even if image is picked
                    enabled: true,
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: provider.pickImageFromGallery,
                    icon: const Icon(Icons.photo_library, color: Colors.blueAccent),
                    label: const Text('Pick an Image from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF232733),
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.blueAccent),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: (provider.inputText.isNotEmpty || provider.pickedImage != null)
                        ? () => provider.submitData(context)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text('ANALYZE'),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}