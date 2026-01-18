import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';

/// Task that runs the pub clean command for the project
/// Uses either flutter clean or dart pub clean depending on the project type
class RunPubCleanTask extends Task<void> {
  /// Creates a new instance of [RunPubCleanTask]
  const RunPubCleanTask(this.project);

  final Project project;

  /// Executes the pub clean task
  /// Runs flutter clean for Flutter projects or dart pub clean for Dart projects
  /// Shows progress with a spinner and handles success or failure
  @override
  Future<void> run() async {
    final spinner = CliSpin(
      text: 'Run pub clean...',
      spinner: CliSpinners.dots,
    ).start();
    try {
      final isFlutter = project.isFlutter;
      if (isFlutter) {
        Process.runSync('flutter', ['clean'], runInShell: true);
      } else {
        Process.runSync('dart', ['pub', 'clean'], runInShell: true);
      }
      spinner.success('Run pub clean successfully.');
    } catch (e) {
      spinner.fail('Run pub clean Failed.');
      rethrow;
    }
  }
}
