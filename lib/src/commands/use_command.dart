import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:psm/src/utils/pubspec_utils.dart';
import 'package:psm/src/utils/yaml_editor.dart';

class UseCommand extends Command {
  @override
  String get name => 'use';

  @override
  String get description => 'Use pubspec according to the flavor';

  @override
  String get invocation {
    var parents = [name];
    for (var command = parent; command != null; command = command.parent) {
      parents.add(command.name);
    }
    parents.add(runner!.executableName);
    var invocation = parents.reversed.join(' ');
    return '$invocation <flavor>';
  }

  UseCommand() {
    argParser.addFlag(
      'pub-clean',
      help: 'Run "pub clean" after use.',
      defaultsTo: true,
      negatable: true,
    );
    argParser.addFlag(
      'pub-get',
      help: 'Run "pub get" after use.',
      defaultsTo: true,
      negatable: true,
    );
  }

  @override
  void run() {
    final arguments = argResults!.rest;

    if (arguments.isEmpty) {
      usageException('Please specify a flavor.');
    } else if (arguments.length > 1) {
      usageException('Please specify only one flavor.');
    }

    final flavor = arguments.first;

    final flavorPubspecName = PubspecUtils.getPubspecNameByFlavor(flavor);
    final flavorPubspecFile = File(flavorPubspecName);
    if (!flavorPubspecFile.existsSync()) {
      throw Exception('No $flavorPubspecName file found.');
    }

    final pubspecName = PubspecUtils.pubspecName;
    final pubspecFile = File(pubspecName);

    if (pubspecFile.existsSync()) {
      final symbolicLinks = pubspecFile.resolveSymbolicLinksSync();
      final isLink = symbolicLinks != pubspecFile.absolute.path;
      if (!isLink) {
        throw Exception("Please run 'psm init' first.");
      }
      pubspecFile.deleteSync();
    }

    PubspecUtils.deleteMergedPubspecFiles(pubspecFile.parent);

    final mergedPubspecName = PubspecUtils.getMergePubspecNameByFlavor(flavor);
    final mergedPubspecFile = File(mergedPubspecName);
    final yamlEditor = YamlEditor.fromFile(flavorPubspecName);
    yamlEditor.writeToFile(mergedPubspecFile);

    Link(pubspecName).createSync(mergedPubspecName);

    final needPubClean = argResults!['pub-clean'] as bool;
    final needPubGet = argResults!['pub-get'] as bool;
    if (needPubClean || needPubGet) {
      final flutterVersion = yamlEditor.getValue(['dependencies', 'flutter']);
      final isFlutter = flutterVersion != null;
      if (needPubClean) {
        _runPubClean(isFlutter: isFlutter);
      }
      if (needPubGet) {
        _runPubGet(isFlutter: isFlutter);
      }
    }
  }

  void _runPubClean({required bool isFlutter}) {
    if (isFlutter) {
      Process.runSync('flutter', ['pub', 'clean'], runInShell: true);
    } else {
      Process.runSync('dart', ['pub', 'clean'], runInShell: true);
    }
  }

  void _runPubGet({required bool isFlutter}) {
    if (isFlutter) {
      Process.runSync('flutter', ['pub', 'get'], runInShell: true);
    } else {
      Process.runSync('dart', ['pub', 'get'], runInShell: true);
    }
  }
}
