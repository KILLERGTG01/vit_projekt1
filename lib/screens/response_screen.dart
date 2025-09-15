import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ResponseScreen extends StatelessWidget {
  const ResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232733),
        title: const Text('Confidence Report', style: TextStyle(color: Colors.blueAccent)),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        elevation: 4,
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
                Color verdictColor;
                if (verdict.toLowerCase().contains('true') || verdict.toLowerCase().contains('secure')) {
                  verdictColor = Colors.blueAccent;
                } else if (verdict.toLowerCase().contains('false') || verdict.toLowerCase().contains('threat')) {
                  verdictColor = Colors.redAccent;
                } else {
                  verdictColor = Colors.orangeAccent;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, color: Colors.blueAccent, size: 60),
                    const SizedBox(height: 24),
                    Card(
                      color: const Color(0xFF232733),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: verdictColor, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              verdict.toUpperCase(),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: verdictColor,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'RobotoMono',
                                    letterSpacing: 2.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Divider(color: verdictColor, thickness: 1.5, height: 28),
                            Text(
                              explanation,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.92),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              
              return const Text("No response data.");
            },
          ),
        ),
      ),
      // Removed bottomNavigationBar with Go Back Home button
    );
  }
}