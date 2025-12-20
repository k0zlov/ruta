# Ruta Generator

The Ruta Generator is a code generation tool for the Ruta framework, inspired
by [dart_frog](https://github.com/VeryGoodOpenSource/dart_frog). It automates the creation of boilerplate code for your
Ruta server, helping you scaffold routes, handlers, and more with ease.

## Features

- **Route Generation**: Automatically generate route handlers and folder structures.
- **Build Runner Integration**: Seamlessly integrates with `build_runner` for code generation.
- **Time-Saving**: Focus on building your application logic instead of writing repetitive code.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dev_dependencies:
  ruta_generator: ^0.1.0
  build_runner: ^2.4.0