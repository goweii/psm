import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:psm/src/utils/pubspec_utils.dart';
import 'package:psm/src/utils/yaml_editor.dart';

class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize flavors pubspec for project.';

  InitCommand();

  @override
  void run() {
    final pubspecName = PubspecUtils.pubspecName;
    final pubspecFile = File(pubspecName);

    if (!pubspecFile.existsSync()) {
      throw Exception('No $pubspecName file found.');
    }

    final symbolicLinks = pubspecFile.resolveSymbolicLinksSync();
    final isLink = symbolicLinks != pubspecFile.absolute.path;

    if (isLink) {
      print('Already initialized.');
      return;
    }

    stdout.write('Please input flavor name (default: base): ');
    String flavor = stdin.readLineSync() ?? '';
    if (flavor.isEmpty) {
      flavor = 'base';
    }

    final flavorPubspecName = PubspecUtils.getPubspecNameByFlavor(flavor);
    final flavorPubspecFile = File(flavorPubspecName);
    if (flavorPubspecFile.existsSync()) {
      throw Exception('$flavorPubspecName file already exists.');
    }
    pubspecFile.copySync(flavorPubspecName);

    final mergedPubspecName = PubspecUtils.getMergePubspecNameByFlavor(flavor);
    final mergedPubspecFile = File(mergedPubspecName);
    if (mergedPubspecFile.existsSync()) {
      mergedPubspecFile.deleteSync();
    }
    final yamlEditor = YamlEditor.fromFile(flavorPubspecName);
    yamlEditor.writeToFile(mergedPubspecFile);

    pubspecFile.deleteSync();

    Link(pubspecName).createSync(mergedPubspecName);
  }
}
