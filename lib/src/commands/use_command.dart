import 'package:args/command_runner.dart';
import 'package:psm/src/tasks/ensure_init_task.dart';
import 'package:psm/src/tasks/run_pub_clean_task.dart';
import 'package:psm/src/tasks/run_pub_get_task.dart';
import 'package:psm/src/tasks/use_flavor_task.dart';
import 'package:psm/src/utils/project.dart';

class UseCommand extends Command {
  @override
  String get name => 'use';

  @override
  String get description => 'Use pubspec according to the flavor';

  @override
  String get invocation {
    var parents = [name];
    for (var command = parent; command != null; command = command.parent) {
      parents.add(command.name);
    }
    parents.add(runner!.executableName);
    var invocation = parents.reversed.join(' ');
    return '$invocation <flavor>';
  }

  UseCommand() {
    argParser.addFlag(
      'pub-clean',
      help: 'Run "pub clean" after use.',
      defaultsTo: true,
      negatable: true,
    );
    argParser.addFlag(
      'pub-get',
      help: 'Run "pub get" after use.',
      defaultsTo: true,
      negatable: true,
    );
  }

  late bool needPubClean = () {
    return argResults!['pub-clean'] as bool;
  }();

  late bool needPubGet = () {
    return argResults!['pub-get'] as bool;
  }();

  late String flavor = () {
    final arguments = argResults!.rest;
    if (arguments.isEmpty) {
      usageException('Please specify a flavor.');
    } else if (arguments.length > 1) {
      usageException('Please specify only one flavor.');
    }
    return arguments.first;
  }();

  @override
  Future<void> run() async {
    final project = Project.current();
    await EnsureInitTask(project).run();
    await UseFlavorTask(project: project, flavor: flavor).run();
    if (needPubClean) {
      await RunPubCleanTask(project).run();
    }
    if (needPubGet) {
      await RunPubGetTask(project).run();
    }
  }
}
