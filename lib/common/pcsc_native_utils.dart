// --- Native Utilities ---

import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

class NativeUtils {
  static ffi.Pointer<ffi.Char> allocateString(String s) {
    return s.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  }

  static String convertString(ffi.Pointer<ffi.Char> s) {
    return s.cast<Utf8>().toDartString();
  }
  
  static ffi.Pointer<ffi.Uint8> allocateBytes(List<int> bytes) {
    final ptr = calloc<ffi.Uint8>(bytes.length);
    ptr.asTypedList(bytes.length).setAll(0, bytes);
    return ptr;
  }

  static List<int> convertBytes(ffi.Pointer<ffi.Uint8> ptr, int length) {
    return ptr.asTypedList(length).toList();
  }

  static Iterable<String> multiStringToDart(ffi.Pointer<Utf8> multiString) sync* {
    while (multiString.cast<ffi.Int8>().value != 0) {
      final length = multiString.length;
      yield multiString.toDartString(length: length);
      multiString = ffi.Pointer.fromAddress(multiString.address + length + 1);
    }
  }
}