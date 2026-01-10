import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:args/args.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/logger.dart';

import 'commands/init_command.dart';
import 'commands/list_command.dart';
import 'commands/use_command.dart';

const String version = '0.0.1-beta.5';
const String name = 'psm';
const String description = '''Pubspec Management
A command line tool to change the pubspec file according to the selected flavor.''';

class PsmCommandRunner extends CommandRunner<void> {
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

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      Logger.info('v$version');
      return;
    }
    return super.runCommand(topLevelResults);
  }
}
