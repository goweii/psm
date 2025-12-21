import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'pubspec_utils.dart';

class YamlEditor {
  YamlEditor();

  factory YamlEditor.fromFile(String filename) {
    final editor = YamlEditor();

    void loadYamlFile(List<String> filenames) {
      final currentFilename = filenames.last;
      final node = loadYamlNode(File(currentFilename).readAsStringSync());
      if (node is! YamlMap) {
        throw Exception('Invalid yaml file: $filename');
      }
      final parentFilename = node[PubspecUtils.dependsOnKey]?.toString();
      if (parentFilename != null) {
        if (filenames.contains(parentFilename)) {
          final names = [...filenames, parentFilename];
          throw Exception('Circular YAML dependency: ${names.join(' -> ')}');
        }
        loadYamlFile([...filenames, parentFilename]);
      }
      editor.mergeYamlMap(node.value);
    }

    loadYamlFile([filename]);

    return editor;
  }

  final _yaml = {};

  void mergeYamlMap(Map other) {
    void mergeMap(Map formMap, Map toMap) {
      for (var entry in formMap.entries) {
        final fromKey = entry.key;
        if (fromKey == PubspecUtils.dependsOnKey) {
          continue;
        }
        final fromValue = entry.value;
        final toValue = toMap[fromKey];
        if (fromValue == null) {
          toMap.remove(fromKey);
        } else if (fromValue is Map) {
          if (toValue != null && toValue is Map) {
            mergeMap(fromValue, toValue);
          } else {
            final newValue = {};
            toMap[fromKey] = newValue;
            mergeMap(fromValue, newValue);
          }
        } else if (fromValue is Iterable) {
          final newValue = fromValue.where((e) => e != null);
          if (toValue != null && toValue is Iterable) {
            toMap[fromKey] = [...toValue, ...newValue];
          } else {
            toMap[fromKey] = [...newValue];
          }
        } else {
          toMap[fromKey] = fromValue;
        }
      }
    }

    mergeMap(other, _yaml);
  }

  dynamic getValue(List<String> path) {
    dynamic current = _yaml;
    for (final key in path) {
      if (current is Map) {
        current = current[key];
      } else {
        break;
      }
    }
    return current;
  }

  void mergeYamlNode(YamlNode other) {
    if (other is YamlMap) {
      mergeYamlMap(other);
    } else {
      throw Exception('Invalid yaml node: $other');
    }
  }

  void mergeYamlString(String other) {
    var node = loadYamlNode(other);
    if (node is YamlMap) {
      mergeYamlMap(node);
    } else {
      throw Exception('Invalid yaml string: $other');
    }
  }

  void mergeYamlFile(File other) {
    var node = loadYamlNode(other.readAsStringSync());
    if (node is YamlMap) {
      mergeYamlMap(node);
    } else {
      throw Exception('Invalid yaml file: ${other.path}');
    }
  }

  void writeToFile(File file) {
    file.writeAsStringSync(toString());
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(PubspecUtils.mergedPubspecNameHeader);
    final yamlWriter = YamlWriter();
    buffer.write(yamlWriter.write(_yaml));
    return buffer.toString();
  }
}
