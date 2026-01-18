import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:psm/src/utils/exceptions.dart';
import 'package:yaml/yaml.dart';

/// Represents a project in the PSM system
/// Contains information about the project directory and pubspec file
class Project {
  /// Creates a new instance of [Project] with the specified directory
  /// Verifies that the directory exists and contains a pubspec.yaml file
  Project(this.rootDir) {
    if (!rootDir.existsSync()) {
      throw TipsException('Project directory not Exist: ${rootDir.path}');
    }
    final pubspecFile = File(p.join(rootDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw TipsException('Not a Dart or Flutter project: ${rootDir.path}');
    }
    this.pubspecFile = pubspecFile;
  }

  /// Factory constructor that creates a [Project] instance for the current working directory
  factory Project.current() => Project(Directory.current);

  final Directory rootDir;

  late final File pubspecFile;

  /// Determines if the project is a Flutter project by checking for 'flutter' dependency
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
