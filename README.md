# pcsc_wrapper

## Overview

`pcsc_wrapper` is a Dart FFI (Foreign Function Interface) wrapper for the PC/SC (Personal Computer/Smart Card) API. It allows you to interact with smart card readers and smart cards directly from your Dart applications.

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Linux** | ✅ Available | Implementation provided. |
| **macOS** | ⚠️ Experimental | Implementation provided. |
| **Windows** | ❌ Not Supported | No implementation available at this time. |

## Features

- **Pure Dart FFI Implementation**: Uses `dart:ffi` to bind directly to system libraries.
- Native bindings to the PC/SC (winscard) interface.
- A Dart-friendly API for common smart card operations.
- Low-level access to readers and cards via Dart's FFI mechanism.
- Lightweight and efficient.

## Prerequisites

- Dart SDK
- PC/SC middleware installed on your system:
  - **Linux**: `libpcsclite1` and `libpcsclite-dev`
  - **macOS**: PCSC framework (usually built-in)

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  pcsc_wrapper: ^[version]
```

## License

This project is licensed under the BSD 3-Clause License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Whether it's testing on macOS, adding Windows support, or fixing bugs, please feel free to submit a Pull Request.