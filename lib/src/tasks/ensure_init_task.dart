import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/project.dart';

import 'check_init_task.dart';

/// Task that ensures the project is initialized before proceeding
/// Throws an exception if the project is not initialized
class EnsureInitTask extends Task<void> {
  /// Creates a new instance of [EnsureInitTask]
  const EnsureInitTask(this.project);

  final Project project;

  /// Executes the task to ensure the project is initialized
  /// Shows a spinner while checking and throws an exception if not initialized
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
