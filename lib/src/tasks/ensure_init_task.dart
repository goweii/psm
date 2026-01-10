import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/project.dart';

import 'check_init_task.dart';

class EnsureInitTask extends Task<void> {
  const EnsureInitTask(this.project);

  final Project project;

  @override
  Future<void> run() async {
    final spinner = CliSpin(
      text: 'Ensure initialized.',
      spinner: CliSpinners.dots,
    ).start();
    try {
      if (await CheckInitTask(project).run()) {
        spinner.success();
      } else {
        throw TipsException('Not initialized. Please run `psm init` first.');
      }
    } catch (e) {
      spinner.fail();
      rethrow;
    }
  }
}
