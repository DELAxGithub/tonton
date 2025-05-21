import 'dart:io';
import 'package:args/args.dart';

/// Simple Dart wrapper around FontForge to generate a TTF icon font from SVG files.
/// Requires `fontforge` to be installed and accessible on the system path.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('svg-dir', defaultsTo: 'assets/icons/svg', help: 'Directory containing SVG icons')
    ..addOption('output-dir', defaultsTo: 'assets/fonts', help: 'Directory to place generated font')
    ..addOption('font-name', defaultsTo: 'TontonIcons', help: 'Font name for the generated TTF')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information');

  final args = parser.parse(arguments);

  if (args['help'] as bool) {
    print('Generate icon font from SVG assets using FontForge.');
    print(parser.usage);
    return;
  }

  final svgDir = Directory(args['svg-dir'] as String);
  final outputDir = Directory(args['output-dir'] as String);
  final fontName = args['font-name'] as String;

  if (!svgDir.existsSync()) {
    stderr.writeln('SVG directory not found: ${svgDir.path}');
    exit(1);
  }

  outputDir.createSync(recursive: true);

  // Check that FontForge is available
  final whichResult = await Process.run('which', ['fontforge']);
  if (whichResult.exitCode != 0) {
    stderr.writeln('FontForge is required but was not found in PATH.');
    exit(1);
  }

  final processResult = await Process.run('fontforge', [
    '-lang=py',
    '-c',
    '''import fontforge, os, sys
font = fontforge.font()
for file in sorted(os.listdir(sys.argv[1])):
    if file.endswith(".svg"):
        glyph = font.createChar(-1, os.path.splitext(file)[0])
        glyph.importOutlines(os.path.join(sys.argv[1], file))
font.generate(os.path.join(sys.argv[2], sys.argv[3] + '.ttf'))''',
    svgDir.path,
    outputDir.path,
    fontName,
  ]);

  stdout.write(processResult.stdout);
  stderr.write(processResult.stderr);

  if (processResult.exitCode != 0) {
    stderr.writeln('Font generation failed with exit code ${processResult.exitCode}.');
    exit(processResult.exitCode);
  }

  print('Generated ${outputDir.path}/$fontName.ttf');
}
