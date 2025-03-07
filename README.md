# pcsc_wrapper

## Overview

pcsc_wrapper is a Dart FFI (Foreign Function Interface) wrapper for the PC/SC (Personal Computer/Smart Card) interface, enabling developers to interact with smart card readers and smart cards using Dart on Linux platforms.

## Platform Support

⚠️ **Platform Limitations**:
- Currently only supports Linux and MacOS
- Only the Linux implementation is tested
- Windows support is not present

## Features

- Native bindings to the PC/SC (winscard) interface
- Provides a Dart-friendly API for smart card operations
- Enables low-level smart card reader and card interactions
- Lightweight and efficient through Dart's FFI mechanism

## Prerequisites

- Dart SDK
- PC/SC middleware installed on your system
- libpcsclite-dev (on Linux)

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  pcsc_wrapper: ^[version]
```

## License

This project is licensed under the BSD 3-Clause License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This library is provided "as-is" with no guarantee of compatibility or support. Users should thoroughly test in their specific environments.