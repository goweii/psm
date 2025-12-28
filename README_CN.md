# PSM - Pubspec Management

PSM (Pubspec Management) 是一个用于管理 Flutter 和 Dart 项目中 pubspec 配置的命令行工具。它允许开发者轻松地切换不同的风味配置，如开发、测试和生产环境，通过管理不同的 pubspec 文件来实现配置的快速切换。

## 功能特性

- **风味配置切换**: 轻松切换不同的 pubspec 配置（如 dev、prod、test 等）
- **配置继承**: 支持从基础配置继承，避免重复定义
- **灵活的配置管理**: 支持多个配置文件之间的合并
- **简单易用**: 提供直观的命令行接口
- **跨项目类型支持**: 支持 Flutter 和 Dart 项目

## 安装

### 通过 pub 全局安装

```bash
dart pub global activate psm
```

## 快速开始

### 1. 初始化项目

在 Flutter 或 Dart 项目根目录下运行：

```bash
psm init
```

此命令会验证当前目录是否为 Flutter 或 Dart 项目。

### 2. 创建配置文件

在项目根目录下创建不同风味的配置文件：

- `pubspec-base.yaml` - 基础配置
- `pubspec-dev.yaml` - 开发环境配置
- `pubspec-prod.yaml` - 生产环境配置

### 3. 配置文件结构

基础配置文件 (`pubspec-base.yaml`) 示例：

```yaml
name: my_flutter_app
description: A new Flutter project.

environment:
  sdk: ">=2.17.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  # ... 其他依赖

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  # ... 其他flutter配置
```

风味特定配置文件可以继承基础配置，并覆盖特定的值：

开发环境配置 (`pubspec-dev.yaml`) 示例：

```yaml
depends_on: pubspec-base.yaml

dependencies:
  # 风味特定的依赖
  mockito: ^5.4.0

flutter:
  # 风味特定的flutter配置
  assets:
    - assets/dev/
```

`depends_on` 字段指定要继承的基础配置文件。

### 4. 列出可用配置

```bash
psm list
```

### 5. 切换到特定风味

```bash
psm use dev
```

这将合并 `pubspec-base.yaml` 和 `pubspec-dev.yaml`，生成最终的 `pubspec.yaml` 文件。

## 详细用法

### 命令说明

#### init 命令

```bash
psm init
```

初始化 PSM 配置。验证当前目录是否为 Flutter 或 Dart 项目。

#### list 命令

```bash
psm list
```

列出所有可用的风味配置。

#### use 命令

```bash
psm use <flavor>
```

切换到指定的风味配置。

参数：
- `<flavor>`: 要切换到的风味名称（如 dev、prod 等）

示例：
```bash
psm use dev      # 切换到开发环境
psm use prod     # 切换到生产环境
psm use test     # 切换到测试环境
```

### 配置文件格式

PSM 使用 YAML 格式的配置文件，支持配置继承。

`depends_on` 字段指定要继承的基础配置文件。

### 配置合并规则

当使用 `psm use <flavor>` 命令时，PSM 会按照以下规则合并配置：

1. 首先加载基础配置文件
2. 然后加载指定风味的配置文件
3. 风味配置文件中的值会覆盖基础配置文件中的同名值
4. 对于 Map 类型的值，会进行深度合并
5. 对于 List 类型的值，会进行追加（可配置替换行为）
6. 依赖项会进行替换而非深度合并
7. 如果子配置中存在同名键的值为空，则会删除该键及其父节点（如果父节点也变空）

## 工作流程示例

### 1. 设置项目

```bash
# 在Flutter项目根目录下
psm init
```

### 2. 创建配置文件

创建以下文件：

- `pubspec-base.yaml` - 包含所有风味共享的基础配置
- `pubspec-dev.yaml` - 包含开发环境特定的配置
- `pubspec-prod.yaml` - 包含生产环境特定的配置

### 3. 切换配置

```bash
# 切换到开发环境
psm use dev

# 清理并获取依赖
flutter clean
flutter pub get

# 运行应用
flutter run

# 切换到生产环境
psm use prod

# 清理并获取依赖
flutter clean
flutter pub get

# 构建应用
flutter build apk
```

## 高级用法

### 多层继承

您可以创建多层继承关系，例如：

```yaml
pubspec-prod.yaml -> pubspec-base.yaml
```

在 `pubspec-prod.yaml` 中指定：

```yaml
depends_on: pubspec-base.yaml
# 生产环境特定配置
```

### 依赖管理

PSM 可以帮助管理不同环境的依赖，例如：

- 开发环境可以包含调试工具依赖
- 测试环境可以包含测试相关依赖
- 生产环境可以移除不必要的开发依赖

## 常见问题

### Q: 配置切换后没有生效？

A: 请确保运行 `flutter clean` 和 `flutter pub get` 来获取新的依赖配置。

### Q: 如何查看当前使用的配置？

A: 运行 `psm list` 命令可以列出所有可用的风味配置。当前激活的配置会在项目根目录的 `pubspec.yaml` 文件中体现。

### Q: 如何添加新的风味配置？

A: 创建一个新文件 `pubspec-{flavor}.yaml`，然后使用 `psm use <flavor>` 命令即可。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进 PSM。

## 许可证

[LICENSE](./LICENSE)
