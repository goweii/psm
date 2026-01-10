import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'package:psm/src/tasks/check_init_task.dart';
import 'package:psm/src/tasks/init_task.dart';
import 'package:psm/src/tasks/input_flavor_task.dart';
import 'package:psm/src/utils/project.dart';

class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize flavors pubspec for project.';

  InitCommand();

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
