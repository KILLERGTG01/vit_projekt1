import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ResponseScreen extends StatelessWidget {
  const ResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Response'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Processing..."),
                  ],
                );
              }

              if (provider.apiError != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    Text("An Error Occurred", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    Text(provider.apiError!, textAlign: TextAlign.center),
                  ],
                );
              }

              if (provider.apiResponse != null) {
                dynamic response = provider.apiResponse;
                if (response is String) {
                  try {
                    response = jsonDecode(response);
                  } catch (_) {
                    response = {"verdict": "", "explanation": provider.apiResponse};
                  }
                }
                String verdict = response["verdict"]?.toString() ?? "No verdict";
                String explanation = response["explanation"]?.toString() ?? "No explanation";
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                    const SizedBox(height: 20),
                    Text("Verdict: $verdict", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    Text(explanation, textAlign: TextAlign.center),
                  ],
                );
              }
              
              return const Text("No response data.");
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: const Text('Go Back Home'),
          onPressed: () {
            Provider.of<AppProvider>(context, listen: false).clearInputs();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}