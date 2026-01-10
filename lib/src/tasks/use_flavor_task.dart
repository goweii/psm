import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';
import 'package:psm/src/utils/yaml_editor.dart';

class UseFlavorTask extends Task<void> {
  const UseFlavorTask({required this.project, required this.flavor});

  final Project project;
  final String flavor;

  @override
  Future<void> run() async {
    final spinner = CliSpin(
      text: "Using flavor '$flavor'...",
      spinner: CliSpinners.dots,
    ).start();
    try {
      final flavorPubspecName = PubspecUtils.getPubspecNameByFlavor(flavor);
      final flavorPubspecFile = File(flavorPubspecName);
      if (!flavorPubspecFile.existsSync()) {
        throw TipsException('No $flavorPubspecName file found.');
      }

      final pubspecName = PubspecUtils.pubspecName;
      final pubspecFile = File(pubspecName);

      if (pubspecFile.existsSync()) {
        final symbolicLinks = pubspecFile.resolveSymbolicLinksSync();
        final isLink = symbolicLinks != pubspecFile.absolute.path;
        if (!isLink) {
          throw TipsException("Please run 'psm init' first.");
        }
        pubspecFile.deleteSync();
      }

      PubspecUtils.deleteMergedPubspecFiles(pubspecFile.parent);

      final mergedPubspecName = PubspecUtils.getMergePubspecNameByFlavor(
        flavor,
      );
      final mergedPubspecFile = File(mergedPubspecName);
      final yamlEditor = YamlEditor.fromFile(flavorPubspecName);
      yamlEditor.writeToFile(mergedPubspecFile);

      Link(pubspecName).createSync(mergedPubspecName);
      spinner.success("Use flavor '$flavor' successfully.");
    } catch (e) {
      spinner.fail("Use flavor '$flavor' failed.");
      rethrow;
    }
  }
}
