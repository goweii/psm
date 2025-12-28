# PSM - Pubspec Management

PSM (Pubspec Management) is a command-line tool for managing pubspec configurations in Flutter and Dart projects. It allows developers to easily switch between different flavor configurations, such as development, testing, and production environments, by managing different pubspec files to achieve quick configuration switching.

[中文文档](./README_CN.md)

## Features

- **Flavor Configuration Switching**: Easily switch between different pubspec configurations (such as dev, prod, test, etc.)
- **Configuration Inheritance**: Supports inheritance from base configurations to avoid duplicate definitions
- **Flexible Configuration Management**: Supports merging between multiple configuration files
- **User-Friendly**: Provides an intuitive command-line interface
- **Cross-Project Type Support**: Supports both Flutter and Dart projects

## Installation

### Install via pub globally

```bash
dart pub global activate psm
```

## Quick Start

### 1. Initialize Project

Run in the root directory of your Flutter or Dart project:

```bash
psm init
```

This command validates whether the current directory is a Flutter or Dart project.

### 2. Create Configuration Files

Create different flavor configuration files in the project root:

- `pubspec-base.yaml` - Base configuration
- `pubspec-dev.yaml` - Development environment configuration
- `pubspec-prod.yaml` - Production environment configuration

### 3. Configuration File Structure

Example of base configuration file (`pubspec-base.yaml`):

```yaml
name: my_flutter_app
description: A new Flutter project.

environment:
  sdk: ">=2.17.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  # ... other dependencies

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  # ... other flutter configurations
```

Flavor-specific configuration files can inherit from the base configuration and override specific values:

Example of development environment configuration (`pubspec-dev.yaml`):

```yaml
depends_on: pubspec-base.yaml

dependencies:
  # Flavor-specific dependencies
  mockito: ^5.4.0

flutter:
  # Flavor-specific flutter configurations
  assets:
    - assets/dev/
```

The `depends_on` field specifies the base configuration file to inherit from.

### 4. List Available Configurations

```bash
psm list
```

### 5. Switch to Specific Flavor

```bash
psm use dev
```

This will merge `pubspec-base.yaml` and `pubspec-dev.yaml` to generate the final `pubspec.yaml` file.

## Detailed Usage

### Command Descriptions

#### init Command

```bash
psm init
```

Initialize PSM configuration. Validates whether the current directory is a Flutter or Dart project.

#### list Command

```bash
psm list
```

List all available flavor configurations.

#### use Command

```bash
psm use <flavor>
```

Switch to the specified flavor configuration.

Parameter:
- `<flavor>`: The flavor name to switch to (such as dev, prod, etc.)

Examples:
```bash
psm use dev      # Switch to development environment
psm use prod     # Switch to production environment
psm use test     # Switch to testing environment
```

### Configuration File Format

PSM uses YAML format configuration files that support configuration inheritance.

The `depends_on` field specifies the base configuration file to inherit from.

### Configuration Merging Rules

When using the `psm use <flavor>` command, PSM merges configurations according to the following rules:

1. First load the base configuration file
2. Then load the specified flavor configuration file
3. Values in the flavor configuration file will override values with the same name in the base configuration file
4. For Map-type values, deep merging is performed
5. For List-type values, appending is performed (replace behavior can be configured)
6. Dependencies will be replaced rather than deep merged
7. If a value in the sub-configuration is null, the key and its parent node (if it also becomes empty) will be removed

## Workflow Example

### 1. Set Up Project

```bash
# In the root directory of a Flutter project
psm init
```

### 2. Create Configuration Files

Create the following files:

- `pubspec-base.yaml` - Contains base configurations shared by all flavors
- `pubspec-dev.yaml` - Contains development environment-specific configurations
- `pubspec-prod.yaml` - Contains production environment-specific configurations

### 3. Switch Configurations

```bash
# Switch to development environment
psm use dev

# Clean and get dependencies
flutter clean
flutter pub get

# Run the app
flutter run

# Switch to production environment
psm use prod

# Clean and get dependencies
flutter clean
flutter pub get

# Build the app
flutter build apk
```

## Advanced Usage

### Multi-level Inheritance

You can create multi-level inheritance relationships, such as:

```yaml
pubspec-prod.yaml -> pubspec-base.yaml
```

In `pubspec-prod.yaml`, specify:

```yaml
depends_on: pubspec-base.yaml
# Production environment-specific configurations
```

### Dependency Management

PSM can help manage dependencies for different environments, such as:

- Development environments can include debugging tool dependencies
- Testing environments can include test-related dependencies
- Production environments can remove unnecessary development dependencies

## Frequently Asked Questions

### Q: Configuration changes don't take effect?

A: Make sure to run `flutter clean` and `flutter pub get` to get the new dependency configurations.

### Q: How to check the current configuration?

A: Run `psm list` command to list all available flavor configurations. The currently active configuration will be reflected in the `pubspec.yaml` file in the project root directory.

### Q: How to add a new flavor configuration?

A: Create a new file `pubspec-{flavor}.yaml`, then use the `psm use <flavor>` command.

## Contributing

Feel free to submit Issues and Pull Requests to improve PSM.

## License

[LICENSE](./LICENSE)
