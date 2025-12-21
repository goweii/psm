import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:args/args.dart';

import 'commands/init_command.dart';
import 'commands/list_command.dart';
import 'commands/use_command.dart';

const String version = '0.0.1-alpha';
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
      print(e);
      exit(64);
    } on Exception catch (e) {
      stderr.writeln(e);
      exit(2);
    }
  }

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.flag('version')) {
      print('v$version');
      return;
    }
    return super.runCommand(topLevelResults);
  }
}
