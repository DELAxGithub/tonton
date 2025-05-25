import 'dart:io';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

// A command-line tool to test image processing functionality
// This helps verify that image compression and format handling works correctly

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('image', abbr: 'i', help: 'Path to the image file to process')
    ..addOption('outdir', abbr: 'o', help: 'Output directory for processed images', defaultsTo: 'processed')
    ..addOption('width', abbr: 'w', help: 'Max width for resized image', defaultsTo: '1024')
    ..addOption('quality', abbr: 'q', help: 'JPEG quality (1-100)', defaultsTo: '85')
    ..addFlag('info', help: 'Only show image info without processing', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information');

  try {
    final args = parser.parse(arguments);

    if (args['help'] == true) {
      printUsage(parser);
      exit(0);
    }

    // Get image path
    String? imagePath = args['image'] as String?;
    if (imagePath == null || imagePath.isEmpty) {
      stdout.writeln('Error: No image path provided.');
      printUsage(parser);
      exit(1);
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      stdout.writeln('Error: File not found: $imagePath');
      exit(1);
    }

    // Read the image file
    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType(imagePath) ?? 'application/octet-stream';
    
    stdout.writeln('\nImage Information:');
    stdout.writeln('- Path: $imagePath');
    stdout.writeln('- Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
    stdout.writeln('- MIME type: $mimeType');

    // Check if we should only show info
    if (args['info'] == true) {
      exit(0);
    }

    // Parse options
    final outdir = args['outdir'] as String;
    final maxWidth = int.parse(args['width'] as String);
    final quality = int.parse(args['quality'] as String);

    // Process the image
    await processImage(file, outdir, maxWidth, quality);

  } catch (e) {
    stdout.writeln('Error: $e');
    printUsage(parser);
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  stdout.writeln('Usage: dart test_image_processing.dart --image=path/to/image.jpg [options]');
  stdout.writeln(parser.usage);
}

Future<void> processImage(File imageFile, String outdir, int maxWidth, int quality) async {
  stdout.writeln('\nProcessing image:');
  stdout.writeln('- Max width: $maxWidth px');
  stdout.writeln('- Quality: $quality%');
  
  // Create output directory if it doesn't exist
  final outputDir = Directory(outdir);
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  
  // Read the image bytes
  final Uint8List imageBytes = await imageFile.readAsBytes();
  
  // Decode the image
  final img.Image? originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) {
    stdout.writeln('Error: Failed to decode image.');
    return;
  }

  stdout.writeln('\nOriginal image:');
  stdout.writeln('- Width: ${originalImage.width} px');
  stdout.writeln('- Height: ${originalImage.height} px');
  stdout.writeln('- Format: ${originalImage.format.name}');
  
  // Check if resizing is needed
  img.Image processedImage = originalImage;
  bool resized = false;
  
  if (originalImage.width > maxWidth) {
    final ratio = originalImage.width / maxWidth;
    final newHeight = (originalImage.height / ratio).round();
    
    stdout.writeln('\nResizing image...');
    processedImage = img.copyResize(
      originalImage,
      width: maxWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
    resized = true;
    
    stdout.writeln('- New width: ${processedImage.width} px');
    stdout.writeln('- New height: ${processedImage.height} px');
  } else {
    stdout.writeln('\nImage is already smaller than max width, skipping resize.');
  }
  
  // Save as JPEG
  final filename = path.basenameWithoutExtension(imageFile.path);
  final jpegOutput = File('$outdir/${filename}_processed.jpg');
  
  stdout.writeln('\nEncoding as JPEG with quality: $quality%');
  final jpegBytes = img.encodeJpg(processedImage, quality: quality);
  await jpegOutput.writeAsBytes(jpegBytes);
  
  // Save as PNG for comparison
  final pngOutput = File('$outdir/${filename}_processed.png');
  final pngBytes = img.encodePng(processedImage);
  await pngOutput.writeAsBytes(pngBytes);
  
  stdout.writeln('\nProcessed images saved:');
  stdout.writeln('- JPEG (${(jpegBytes.length / 1024).toStringAsFixed(2)} KB): ${jpegOutput.path}');
  stdout.writeln('- PNG (${(pngBytes.length / 1024).toStringAsFixed(2)} KB): ${pngOutput.path}');
  
  stdout.writeln('\nCompression results:');
  stdout.writeln('- Original size: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB');
  stdout.writeln('- JPEG size: ${(jpegBytes.length / 1024).toStringAsFixed(2)} KB (${(100 * jpegBytes.length / imageBytes.length).toStringAsFixed(1)}%)');
  stdout.writeln('- PNG size: ${(pngBytes.length / 1024).toStringAsFixed(2)} KB (${(100 * pngBytes.length / imageBytes.length).toStringAsFixed(1)}%)');
  
  if (resized) {
    stdout.writeln('- Resized: Yes (from ${originalImage.width}x${originalImage.height} to ${processedImage.width}x${processedImage.height})');
  } else {
    stdout.writeln('- Resized: No');
  }
}