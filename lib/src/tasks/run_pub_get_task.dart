import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';

class RunPubGetTask extends Task<void> {
  const RunPubGetTask(this.project);

  final Project project;

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
