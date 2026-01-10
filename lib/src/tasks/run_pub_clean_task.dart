import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';

class RunPubCleanTask extends Task<void> {
  const RunPubCleanTask(this.project);

  final Project project;

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
