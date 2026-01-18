import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';

/// Task that runs the pub get command for the project
/// Uses either flutter pub get or dart pub get depending on the project type
class RunPubGetTask extends Task<void> {
  /// Creates a new instance of [RunPubGetTask]
  const RunPubGetTask(this.project);

  final Project project;

  /// Executes the pub get task
  /// Runs flutter pub get for Flutter projects or dart pub get for Dart projects
  /// Shows progress with a spinner and handles success or failure
  @override
  Future<void> run() async {
    final spinner = CliSpin(
      text: 'Run pub get...',
      spinner: CliSpinners.dots,
    ).start();
    try {
      final isFlutter = project.isFlutter;
      if (isFlutter) {
        Process.runSync('flutter', ['pub', 'get'], runInShell: true);
      } else {
        Process.runSync('dart', ['pub', 'get'], runInShell: true);
      }
      spinner.success('Run pub get successfully.');
    } catch (e) {
      spinner.fail('Run pub get failed.');
      rethrow;
    }
  }
}
