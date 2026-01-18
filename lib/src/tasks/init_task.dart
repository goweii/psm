import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';
import 'package:psm/src/utils/yaml_editor.dart';

/// Task that initializes the project for flavor management
/// Creates the initial flavor configuration files and sets up symbolic links
class InitTask extends Task<void> {
  /// Creates a new instance of [InitTask]
  const InitTask({required this.project, required this.flavor});

  final Project project;

  final String flavor;

  /// Executes the initialization task
  /// Creates flavor-specific pubspec file, sets up symbolic links, and shows progress with a spinner
  @override
  Future<void> run() async {
    final spinner = CliSpin(
      text: 'Initializing...',
      spinner: CliSpinners.dots,
    ).start();
    try {
      final flavorPubspecName = PubspecUtils.getPubspecNameByFlavor(flavor);
      final flavorPubspecFile = File(flavorPubspecName);
      if (flavorPubspecFile.existsSync()) {
        throw TipsException('The $flavorPubspecName file already exists.');
      }
      project.pubspecFile.copySync(flavorPubspecName);

      final mergedPubspecName = PubspecUtils.getMergePubspecNameByFlavor(
        flavor,
      );
      final mergedPubspecFile = File(mergedPubspecName);
      if (mergedPubspecFile.existsSync()) {
        mergedPubspecFile.deleteSync();
      }
      final yamlEditor = YamlEditor.fromFile(flavorPubspecName);
      yamlEditor.writeToFile(mergedPubspecFile);

      project.pubspecFile.deleteSync();

      Link(project.pubspecFile.path).createSync(mergedPubspecName);

      spinner.success('Initialize successfully.');
    } on TipsException catch (_) {
      spinner.fail('Initialize failed.');
      rethrow;
    } catch (e) {
      spinner.fail('Initialize failed.');
      rethrow;
    }
  }
}
