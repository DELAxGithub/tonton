import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:args/args.dart';

// Usage: dart test_edge_function.dart --image=path/to/image.jpg [--url=SUPABASE_URL] [--key=SUPABASE_ANON_KEY]

void main(List<String> arguments) async {
  // Parse command-line arguments
  final parser =
      ArgParser()
        ..addOption('image', abbr: 'i', help: 'Path to the image file to test')
        ..addOption(
          'url',
          abbr: 'u',
          help: 'Supabase URL (optional if env vars are set)',
        )
        ..addOption(
          'key',
          abbr: 'k',
          help: 'Supabase Anon Key (optional if env vars are set)',
        )
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Show usage information',
        );

  try {
    final args = parser.parse(arguments);

    if (args['help'] == true) {
      printUsage(parser);
      exit(0);
    }

    // Get image path from args or prompt
    String? imagePath = args['image'] as String?;
    if (imagePath == null || imagePath.isEmpty) {
      print('Error: No image path provided.');
      printUsage(parser);
      exit(1);
    }

    // Get Supabase URL and key
    final supabaseUrl =
        args['url'] as String? ??
        Platform.environment['SUPABASE_URL'] ??
        promptForInput('Enter Supabase URL:');

    final supabaseAnonKey =
        args['key'] as String? ??
        Platform.environment['SUPABASE_ANON_KEY'] ??
        promptForInput('Enter Supabase Anon Key:');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      print('Error: Supabase URL and Anon Key are required.');
      exit(1);
    }

    await testEdgeFunction(imagePath, supabaseUrl, supabaseAnonKey);
  } catch (e) {
    print('Error parsing arguments: $e');
    printUsage(parser);
    exit(1);
  }
}

/// Prompt the user for input
String promptForInput(String prompt) {
  stdout.write('$prompt ');
  return stdin.readLineSync() ?? '';
}

/// Show usage information
void printUsage(ArgParser parser) {
  print(
    'Usage: dart test_edge_function.dart --image=path/to/image.jpg [--url=SUPABASE_URL] [--key=SUPABASE_ANON_KEY]',
  );
  print(parser.usage);
}

/// Test the Edge Function with the given image
Future<void> testEdgeFunction(
  String imagePath,
  String supabaseUrl,
  String supabaseAnonKey,
) async {
  final file = File(imagePath);

  if (!await file.exists()) {
    print('Error: File not found: $imagePath');
    exit(1);
  }

  print('\nTesting Edge Function "process-image-gemini" with:');
  print('- Image: $imagePath');
  print('- Supabase URL: $supabaseUrl');

  // Read and encode the image
  final bytes = await file.readAsBytes();
  final base64Image = base64Encode(bytes);
  final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';

  print('\nImage details:');
  print('- Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
  print('- MIME type: $mimeType');

  // Build the request URL
  final functionUrl = '$supabaseUrl/functions/v1/process-image-gemini';
  print('\nSending request to: $functionUrl');

  // Start timer
  final startTime = DateTime.now();
  print('Request started at: $startTime');

  try {
    // Call the Edge Function
    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseAnonKey',
      },
      body: jsonEncode({'imageData': base64Image, 'mimeType': mimeType}),
    );

    // Calculate duration
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print(
      'Request completed in: ${duration.inSeconds}.${duration.inMilliseconds % 1000} seconds',
    );

    // Process the response
    print('\nResponse status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Success! Response body:');
      // Pretty print the JSON response
      final jsonResponse = jsonDecode(response.body);
      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonResponse);
      print(prettyJson);

      // Summarize the key nutrition information
      print('\nNutrition Summary:');
      print('- Food Name: ${jsonResponse['food_name']}');
      print('- Calories: ${jsonResponse['calories']} kcal');
      print('- Protein: ${jsonResponse['protein_g']} g');
      print('- Fat: ${jsonResponse['fat_g']} g');
      print('- Carbs: ${jsonResponse['carbs_g']} g');
    } else {
      print('Error! Response body:');
      print(response.body);
    }
  } catch (e) {
    print('\nException during request: $e');
  }
}
