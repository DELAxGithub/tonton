import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

// Configuration to check
const requiredEnvVars = [
  'SUPABASE_URL',
  'SUPABASE_ANON_KEY',
];

const requiredDependencies = [
  'image_picker',
  'supabase_flutter',
  'image',
  'mime',
  'flutter_riverpod',
];

Future<void> main() async {
  print('Tonton Image Analysis Configuration Verification');
  print('===============================================\n');
  
  var allChecksPassed = true;
  
  // Check pubspec.yaml for dependencies
  allChecksPassed = await checkDependencies() && allChecksPassed;
  
  // Check for environment variables
  allChecksPassed = checkEnvironmentVariables() && allChecksPassed;
  
  // Check Edge Function accessibility
  allChecksPassed = await checkEdgeFunction() && allChecksPassed;
  
  // Check for required model classes
  allChecksPassed = await checkRequiredFiles() && allChecksPassed;
  
  // Summary
  print('\nVerification complete!');
  if (allChecksPassed) {
    print('✅ All checks passed! The project is properly configured for image analysis.');
  } else {
    print('❌ Some checks failed. Please address the issues above before using the image analysis feature.');
  }
}

Future<bool> checkDependencies() async {
  print('Checking dependencies in pubspec.yaml...');
  
  try {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('❌ pubspec.yaml file not found!');
      return false;
    }
    
    final yamlContent = await pubspecFile.readAsString();
    final yaml = loadYaml(yamlContent);
    
    if (yaml['dependencies'] == null) {
      print('❌ No dependencies section found in pubspec.yaml!');
      return false;
    }
    
    final dependencies = yaml['dependencies'] as YamlMap;
    
    bool allDependenciesFound = true;
    for (final dep in requiredDependencies) {
      if (!dependencies.containsKey(dep)) {
        print('❌ Missing required dependency: $dep');
        allDependenciesFound = false;
      } else {
        print('✅ Found dependency: $dep => ${dependencies[dep]}');
      }
    }
    
    return allDependenciesFound;
  } catch (e) {
    print('❌ Error checking dependencies: $e');
    return false;
  }
}

bool checkEnvironmentVariables() {
  print('\nChecking environment variables...');
  
  bool allVarsFound = true;
  for (final envVar in requiredEnvVars) {
    final value = Platform.environment[envVar];
    if (value == null || value.isEmpty) {
      print('❌ Missing environment variable: $envVar');
      allVarsFound = false;
    } else {
      print('✅ Found environment variable: $envVar');
    }
  }
  
  return allVarsFound;
}

Future<bool> checkEdgeFunction() async {
  print('\nChecking Supabase Edge Function accessibility...');
  
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseAnonKey = Platform.environment['SUPABASE_ANON_KEY'];
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ Cannot check Edge Function without SUPABASE_URL and SUPABASE_ANON_KEY environment variables.');
    return false;
  }
  
  try {
    // Try a HEAD request instead of OPTIONS to check if the function exists
    final response = await http.head(
      Uri.parse('$supabaseUrl/functions/v1/process-image-gemini'),
      headers: {
        'Authorization': 'Bearer $supabaseAnonKey',
      },
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Edge Function "process-image-gemini" is accessible.');
      return true;
    } else {
      print('❌ Edge Function "process-image-gemini" returned status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ Error checking Edge Function accessibility: $e');
    return false;
  }
}

Future<bool> checkRequiredFiles() async {
  print('\nChecking for required model classes and services...');
  
  final requiredFiles = [
    'lib/models/estimated_meal_nutrition.dart',
    'lib/models/nutrient_info.dart',
    'lib/services/ai_service.dart',
    'lib/providers/ai_estimation_provider.dart',
  ];
  
  bool allFilesFound = true;
  for (final filePath in requiredFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      print('✅ Found required file: $filePath');
    } else {
      print('❌ Missing required file: $filePath');
      allFilesFound = false;
    }
  }
  
  return allFilesFound;
}