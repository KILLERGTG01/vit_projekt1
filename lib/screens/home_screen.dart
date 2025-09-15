import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart'; 
import '../providers/app_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription _intentDataStreamSubscription;
  final TextEditingController _textController = TextEditingController();

@override
void initState() {
  super.initState();

  final provider = Provider.of<AppProvider>(context, listen: false);
  _intentDataStreamSubscription =
      ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      provider.setSharedImage(File(files.first.path));
      _textController.clear();
    }
  }, onError: (err) {
    debugPrint("getMediaStream error: $err");
  });

  ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      provider.setSharedImage(File(files.first.path));
      _textController.clear();
    }
    ReceiveSharingIntent.instance.reset();
  });
}


  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (_textController.text != provider.inputText && provider.pickedImage == null) {
            _textController.text = provider.inputText;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('VIT Project'),
            actions: [
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
                  if (provider.pickedImage != null)
                    Container(
                      height: 200,
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
                  TextField(
                    controller: _textController,
                    onChanged: (text) => provider.setInputText(text),
                    decoration: const InputDecoration(
                      labelText: 'Enter text or share content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    enabled: provider.pickedImage == null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: provider.pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Image from Gallery'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: (provider.inputText.isNotEmpty || provider.pickedImage != null)
                        ? () => provider.submitData(context)
                        : null, 
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