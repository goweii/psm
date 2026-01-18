import 'package:args/command_runner.dart';
import 'package:psm/src/tasks/get_current_flavors_task.dart';
import 'package:psm/src/tasks/get_flavor_dependiencies_task.dart';
import 'package:psm/src/tasks/list_available_flavors_task.dart';
import 'package:psm/src/utils/logger.dart';
import 'package:psm/src/utils/project.dart';

/// A command that lists all available flavors in the project
class ListCommand extends Command {
  @override
  String get name => 'list';

  @override
  String get description => 'List all available flavors';

  /// Creates a new instance of [ListCommand]
  /// Sets up the 'show-dependency' flag for displaying dependency chain
  ListCommand() {
    argParser.addFlag(
      'show-dependency',
      abbr: 'd',
      help: 'Show YAML dependency',
      defaultsTo: false,
      negatable: false,
    );
  }

  /// Gets the value of the show-dependency flag
  late bool showDependency = () {
    return argResults!['show-dependency'] as bool;
  }();

  /// Executes the list command
  /// Retrieves current flavor, available flavors, and their dependencies (if requested)
  /// Then displays them in a formatted list
  @override
  Future<void> run() async {
    final project = Project.current();

    final currentFlavor = await GetCurrentFlavorsTask(project).run();
    final availableFlavors = await ListAvailableFlavorsTask(project).run();
    final flavorDependiencies = <String, List<String>>{};
    if (showDependency) {
      for (final flavor in availableFlavors) {
        final dependiencies = await GetFlavorDependienciesTask(
          project: project,
          flavor: flavor,
        ).run();
        flavorDependiencies[flavor] = dependiencies;
      }
    }

    if (availableFlavors.length > 1) {
      Logger.success('There are ${availableFlavors.length} flavors available:');
    } else {
      Logger.success('There is ${availableFlavors.length} flavor available:');
    }

    for (var flavor in availableFlavors) {
      final isCurrent = currentFlavor == flavor;
      final buffer = StringBuffer();
      if (isCurrent) {
        buffer.write('* $flavor');
      } else {
        buffer.write('  $flavor');
      }
      if (showDependency) {
        final depends = flavorDependiencies[flavor];
        if (depends != null && depends.length > 1) {
          buffer.write(' -> ');
          buffer.write(depends.skip(1).join(' -> '));
        }
      }
      if (isCurrent) {
        Logger.info(buffer.toString());
      } else {
        Logger.log(buffer.toString());
      }
    }
  }
}
