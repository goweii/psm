import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/check_init_task.dart';
import 'package:psm/src/tasks/init_task.dart';
import 'package:psm/src/tasks/input_flavor_task.dart';
import 'package:psm/src/utils/project.dart';

/// A command that initializes flavor pubspec for the project
class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize flavors pubspec for project.';

  /// Creates a new instance of [InitCommand]
  InitCommand();

  /// Executes the initialization command
  /// First checks if the project is already initialized
  /// Then gets flavor name from user input and runs the initialization task
  @override
  Future<void> run() async {
    final project = Project.current();
    if (await CheckInitTask(project).run()) {
      CliSpin().success('Already Initialized.');
      return;
    }
    final flavor = await InputFlavorTask().run();
    await InitTask(project: project, flavor: flavor).run();
  }
}
