import 'package:args/command_runner.dart';
import 'package:psm/src/tasks/ensure_init_task.dart';
import 'package:psm/src/tasks/run_pub_clean_task.dart';
import 'package:psm/src/tasks/run_pub_get_task.dart';
import 'package:psm/src/tasks/use_flavor_task.dart';
import 'package:psm/src/utils/project.dart';

/// A command that switches to a specific flavor configuration
class UseCommand extends Command {
  @override
  String get name => 'use';

  @override
  String get description => 'Use pubspec according to the flavor';

  /// Returns the usage string for this command
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

  /// Creates a new instance of [UseCommand]
  /// Sets up flags for pub-clean and pub-get operations
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

  /// Determines whether to run pub clean after applying the flavor
  late bool needPubClean = () {
    return argResults!['pub-clean'] as bool;
  }();

  /// Determines whether to run pub get after applying the flavor
  late bool needPubGet = () {
    return argResults!['pub-get'] as bool;
  }();

  /// Gets the flavor name from command arguments
  /// Throws an exception if no flavor or multiple flavors are specified
  late String flavor = () {
    final arguments = argResults!.rest;
    if (arguments.isEmpty) {
      usageException('Please specify a flavor.');
    } else if (arguments.length > 1) {
      usageException('Please specify only one flavor.');
    }
    return arguments.first;
  }();

  /// Executes the use command
  /// Ensures the project is initialized, applies the specified flavor,
  /// and optionally runs pub clean and pub get
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
