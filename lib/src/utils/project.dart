import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:psm/src/utils/exceptions.dart';
import 'package:yaml/yaml.dart';

class Project {
  Project(this.rootDir) {
    if (!rootDir.existsSync()) {
      throw TipsException('Project directory not exist: ${rootDir.path}');
    }
    final pubspecFile = File(p.join(rootDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw TipsException('Not a Dart or Flutter project: ${rootDir.path}');
    }
    this.pubspecFile = pubspecFile;
  }

  factory Project.current() => Project(Directory.current);

  final Directory rootDir;

  late final File pubspecFile;

  bool get isFlutter {
    final pubspecFile = this.pubspecFile;
    if (!pubspecFile.existsSync()) {
      return false;
    }
    final yaml = loadYaml(pubspecFile.readAsStringSync());
    if (yaml is! YamlMap) {
      return false;
    }
    final dependencies = yaml['dependencies'];
    if (dependencies == null) {
      return false;
    }
    if (dependencies is! YamlMap) {
      return false;
    }
    return dependencies.containsKey('flutter');
  }
}
