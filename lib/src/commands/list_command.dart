import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:args/command_runner.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

class ListCommand extends Command {
  @override
  String get name => 'list';

  @override
  String get description => 'List all available flavors';

  ListCommand() {
    argParser.addFlag(
      'show-dependency',
      help: 'Show YAML dependency',
      defaultsTo: false,
      negatable: false,
    );
  }

  @override
  void run() {
    final showDependency = argResults!['show-dependency'] as bool;

    final dir = Directory.current;

    final favors = <String>[];

    final fileList = dir.listSync().whereType<File>();
    for (var file in fileList) {
      final basename = path.basename(file.path);
      final flavor = PubspecUtils.getFlavorFromPubspecName(basename);
      if (flavor.isNotEmpty) {
        favors.add(flavor);
      }
    }

    String? currentFlavor;

    final pubspecFile = File(PubspecUtils.pubspecName);
    if (pubspecFile.existsSync()) {
      final symbolicLinks = pubspecFile.resolveSymbolicLinksSync();
      final isLink = symbolicLinks != pubspecFile.absolute.path;
      if (isLink) {
        final filename = path.basename(symbolicLinks);
        final flavor = PubspecUtils.getFlavorFromMergedPubspecName(filename);
        if (flavor.isNotEmpty) {
          currentFlavor = flavor;
        }
      }
    }

    final dependiencies = <String, List<String>>{};
    if (showDependency) {
      for (var flavor in favors) {
        final filename = PubspecUtils.getPubspecNameByFlavor(flavor);
        final depends = PubspecUtils.getDependencyFromPubspecName(filename);
        dependiencies[flavor] = depends
            .map((e) => PubspecUtils.getFlavorFromPubspecName(e))
            .toList();
      }
    }

    print('There are ${favors.length} flavors available:');

    for (var flavor in favors) {
      final buffer = StringBuffer();

      if (currentFlavor == flavor) {
        buffer.write('* $flavor (current)');
      } else {
        buffer.write('  $flavor');
      }

      if (showDependency) {
        final depends = dependiencies[flavor];
        if (depends != null && depends.length > 1) {
          buffer.write(' -> ');
          buffer.write(depends.skip(1).join(' -> '));
        }
      }

      print(buffer.toString());
    }
  }
}
