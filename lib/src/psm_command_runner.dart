import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:args/args.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/logger.dart';

import 'commands/init_command.dart';
import 'commands/list_command.dart';
import 'commands/use_command.dart';

/// Version of the PSM package
const String version = '0.0.3';

/// Name of the PSM package
const String name = 'psm';

/// Description of the PSM package
const String description = '''Pubspec Management
A command line tool to change the pubspec file according to the selected flavor.''';

/// Command runner for PSM (Pubspec Management) tool
/// Handles initialization, listing and switching between different flavors of pubspec configuration
class PsmCommandRunner extends CommandRunner<void> {
  /// Creates a new instance of [PsmCommandRunner]
  /// Sets up basic flags and registers all available commands
  PsmCommandRunner() : super(name, description) {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version.',
    );

    addCommand(InitCommand());
    addCommand(ListCommand());
    addCommand(UseCommand());
  }

  /// Runs the command with the given arguments
  /// Handles different types of exceptions and exits with appropriate codes
  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      Logger.info(e.usage);
      exit(64);
    } on TipsException catch (e) {
      Logger.error(e.message);
      exit(1);
    } on Exception catch (e) {
      Logger.error(e.toString());
      exit(2);
    }
  }

  /// Executes a command with the top-level results
  /// Checks for version flag before executing the command
  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      Logger.info('v$version');
      return;
    }
    return super.runCommand(topLevelResults);
  }
}
