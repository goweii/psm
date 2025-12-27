import 'dart:convert';
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
      final node = loadYaml(File(currentFilename).readAsStringSync());
      final map = jsonDecode(jsonEncode(node));
      if (map is! Map) {
        throw Exception('Invalid yaml file: $filename');
      }
      final parentFilename = map[PubspecUtils.dependsOnKey]?.toString();
      if (parentFilename != null) {
        if (filenames.contains(parentFilename)) {
          final names = [...filenames, parentFilename];
          throw Exception('Circular YAML dependency: ${names.join(' -> ')}');
        }
        loadYamlFile([...filenames, parentFilename]);
      }
      editor.merge(map);
    }

    loadYamlFile([filename]);

    return editor;
  }

  final _yaml = {};

  void merge(dynamic other) {
    dynamic yaml = other;
    if (yaml is File) {
      yaml = yaml.readAsStringSync();
    }
    if (yaml is String) {
      yaml = loadYaml(yaml);
    }
    if (yaml is YamlMap) {
      _mergeMap([], jsonDecode(jsonEncode(yaml)));
    }
    if (yaml is Map) {
      _mergeMap([], yaml);
    } else {
      throw Exception('Invalid yaml: $other');
    }
  }

  bool has(List<String> path) {
    bool contains = true;
    dynamic current = _yaml;
    for (var key in path) {
      if (current is Map) {
        contains = current.containsKey(key);
        if (!contains) {
          break;
        } else {
          current = current[key];
        }
      } else {
        contains = false;
        break;
      }
    }
    return contains;
  }

  dynamic remove(List<String> path) {
    if (path.isEmpty) {
      _yaml.clear();
      return;
    }
    dynamic current = _yaml;
    if (path.length > 1) {
      current = get(path.sublist(0, path.length - 1));
    }
    if (current is Map) {
      return current.remove(path.last);
    }
    return null;
  }

  dynamic get(List<String> path) {
    dynamic current = _yaml;
    for (var key in path) {
      if (current is Map) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  void set(List<String> path, dynamic value) {
    void setToMap(Map map, List<String> path, dynamic value) {
      if (path.isEmpty) {
        return;
      }
      final key = path.first;
      if (path.length == 1) {
        if (value == null) {
          map.remove(key);
        } else {
          map[key] = value;
        }
        return;
      }
      var next = map[key];
      if (next == null) {
        next = {};
        map[key] = next;
      }
      if (next is! Map) {
        throw Exception('Invalid yaml path: $path');
      }
      setToMap(next, path.sublist(1), value);
    }

    if (value is Map) {
      value = value.toEditableMap();
      value.removeNullValues();
    }
    setToMap(_yaml, path, value);
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

  void _mergeMap(List<String> path, Map map) {
    for (var entry in map.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      final newPath = [...path, key];

      if (value == null) {
        remove(newPath);
        continue;
      }

      if (_shouldIgnorePath.has(newPath)) {
        continue;
      }
      if (_shouldReplacePath.has(newPath)) {
        set(newPath, value);
        continue;
      }

      if (value is Map) {
        _mergeMap(newPath, value);
      } else {
        set(newPath, value);
      }
    }
  }

  static final List<List<String>> _shouldIgnorePath = [
    [PubspecUtils.dependsOnKey],
  ];

  static final List<List<String>> _shouldReplacePath = [
    ['dependencies'],
    ['dev_dependencies'],
    ['dependency_overrides'],
  ];
}

extension _PathExtension on List<String> {
  bool equals(List<String> other) {
    if (length != other.length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }
}

extension _PathListExtension on List<List<String>> {
  bool has(List<String> path) {
    for (var other in this) {
      if (other.equals(path)) {
        return true;
      }
    }
    return false;
  }
}

extension _MapExtension on Map {
  /// 移除map中为null的key，如果移除key后父节点为null，则移除父节点
  void removeNullValues() {
    // 先递归处理所有子Map
    for (var entry in Map.from(this).entries) {
      if (entry.value is Map) {
        (entry.value as Map).removeNullValues();
        // 如果子map经过处理后变为空，需要从父map中移除该key
        if ((entry.value as Map).isEmpty) {
          remove(entry.key);
        }
      } else if (entry.value is List) {
        // 如果值是List，需要处理List中的Map元素
        (entry.value as List).removeNullValues();
        // 如果List变为空，也需要移除
        if ((entry.value as List).isEmpty) {
          remove(entry.key);
        }
      }
    }

    // 然后移除当前Map中值为null的键
    final keysToRemove = <dynamic>[];
    for (var entry in entries) {
      if (entry.value == null) {
        keysToRemove.add(entry.key);
      }
    }

    for (var key in keysToRemove) {
      remove(key);
    }
  }

  /// 转为可编辑的map，包括嵌套
  Map toEditableMap() {
    final result = <dynamic, dynamic>{};
    for (var entry in entries) {
      if (entry.value is Map) {
        result[entry.key] = (entry.value as Map).toEditableMap();
      } else if (entry.value is List) {
        result[entry.key] = (entry.value as List).toEditableList();
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

extension _ListExtension on List {
  /// 转为可编辑的list，包括嵌套
  List toEditableList() {
    final result = <dynamic>[];
    for (var item in this) {
      if (item is Map) {
        result.add(item.toEditableMap());
      } else if (item is List) {
        result.add(item.toEditableList());
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// 处理List中的Map元素，移除其中的null键
  void removeNullValues() {
    // 从后往前遍历，避免在移除元素时影响索引
    for (int i = length - 1; i >= 0; i--) {
      if (this[i] is Map) {
        (this[i] as Map).removeNullValues();
        // 如果Map处理后变为空，从List中移除它
        if ((this[i] as Map).isEmpty) {
          removeAt(i);
        }
      } else if (this[i] is List) {
        (this[i] as List).removeNullValues();
        // 如果List处理后变为空，从父List中移除它
        if ((this[i] as List).isEmpty) {
          removeAt(i);
        }
      }
    }
  }
}
