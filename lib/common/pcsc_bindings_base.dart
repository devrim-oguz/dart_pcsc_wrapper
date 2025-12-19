import 'dart:async';
import 'dart:isolate';

import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

import 'package:pcsc_wrapper/common/pcsc_types.dart';

/// Message wrapper for sending commands to the isolate
class CommandMessage {
  final PcscCommand command;
  final SendPort replyPort;
  CommandMessage(this.command, this.replyPort);
}

/// Abstract context that platform-specific implementations must provide
abstract class PcscContext {}

/// Abstract command that all platform-specific commands must implement
abstract class PcscCommand<T> {
  T execute(PcscContext ctx);
}

/// Command factory interface - platform bindings implement this
abstract class PcscCommandFactory {
  PcscCommand<PcscResult<SCardContext>> establishContext(int dwScope);
  PcscCommand<SCardResult> releaseContext(int hContext);
  PcscCommand<SCardResult> isValidContext(int hContext);
  PcscCommand<PcscResult<SCardHandle>> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols);
  PcscCommand<PcscResult<SCardHandle>> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization);
  PcscCommand<SCardResult> disconnect(int hCard, int dwDisposition);
  PcscCommand<SCardResult> beginTransaction(int hCard);
  PcscCommand<SCardResult> endTransaction(int hCard, int dwDisposition);
  PcscCommand<PcscResult<SCardStatus>> status(int hCard);
  PcscCommand<PcscResult<List<SCardReaderState>>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates);
  PcscCommand<PcscResult<List<int>>> control(int hCard, int dwControlCode, List<int> pbSendBuffer);
  PcscCommand<PcscResult<List<int>>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer);
  PcscCommand<PcscResult<List<String>>> listReaderGroups(int hContext);
  PcscCommand<PcscResult<List<String>>> listReaders(int hContext);
  PcscCommand<SCardResult> cancel(int hContext);
  PcscCommand<PcscResult<List<int>>> getAttrib(int hCard, int dwAttrId);
  PcscCommand<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr);
}

/// Centralized command executor that handles isolate communication
class PcscCommandExecutor {
  Isolate? _isolate;
  SendPort? _commandPort;
  final Completer<void> _isolateReady = Completer<void>();

  static final Finalizer<Isolate> _finalizer = Finalizer((isolate) {
    isolate.kill(priority: Isolate.immediate);
  });

  PcscCommandExecutor(void Function(SendPort) isolateEntryPoint) {
    _initIsolate(isolateEntryPoint);
  }

  Future<void> _initIsolate(void Function(SendPort) entryPoint) async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(entryPoint, receivePort.sendPort);
    _finalizer.attach(this, _isolate!, detach: this);
    _commandPort = await receivePort.first as SendPort;
    _isolateReady.complete();
  }

  Future<T> execute<T>(PcscCommand<T> command) async {
    await _isolateReady.future;
    final responsePort = ReceivePort();
    _commandPort!.send(CommandMessage(command, responsePort.sendPort));
    final result = await responsePort.first;
    if (result is Exception) throw result;
    return result as T;
  }

  void dispose() {
    _finalizer.detach(this);
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

/// Base class for PC/SC bindings - combines interface and implementation
abstract class PcscBindings {
  late final PcscCommandExecutor _executor;
  late final PcscCommandFactory _factory;

  PcscBindings() {
    _factory = createCommandFactory();
    _executor = PcscCommandExecutor(isolateEntryPoint);
  }

  /// Platform-specific isolate entry point
  void Function(SendPort) get isolateEntryPoint;

  /// Platform-specific command factory
  PcscCommandFactory createCommandFactory();

  void dispose() => _executor.dispose();

  // Public API
  Future<PcscResult<SCardContext>> establishContext(int dwScope) =>
      _executor.execute(_factory.establishContext(dwScope));

  Future<SCardResult> releaseContext(int hContext) =>
      _executor.execute(_factory.releaseContext(hContext));

  Future<SCardResult> isValidContext(int hContext) =>
      _executor.execute(_factory.isValidContext(hContext));

  Future<PcscResult<SCardHandle>> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) =>
      _executor.execute(_factory.connect(hContext, szReader, dwShareMode, dwPreferredProtocols));

  Future<PcscResult<SCardHandle>> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) =>
      _executor.execute(_factory.reconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization));

  Future<SCardResult> disconnect(int hCard, int dwDisposition) =>
      _executor.execute(_factory.disconnect(hCard, dwDisposition));

  Future<SCardResult> beginTransaction(int hCard) =>
      _executor.execute(_factory.beginTransaction(hCard));

  Future<SCardResult> endTransaction(int hCard, int dwDisposition) =>
      _executor.execute(_factory.endTransaction(hCard, dwDisposition));

  Future<PcscResult<SCardStatus>> status(int hCard) =>
      _executor.execute(_factory.status(hCard));

  Future<PcscResult<List<SCardReaderState>>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) =>
      _executor.execute(_factory.getStatusChange(hContext, dwTimeout, rgReaderStates));

  Future<PcscResult<List<int>>> control(int hCard, int dwControlCode, List<int> pbSendBuffer) =>
      _executor.execute(_factory.control(hCard, dwControlCode, pbSendBuffer));

  Future<PcscResult<List<int>>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) =>
      _executor.execute(_factory.transmit(hCard, pioSendPci, pbSendBuffer));

  Future<PcscResult<List<String>>> listReaderGroups(int hContext) =>
      _executor.execute(_factory.listReaderGroups(hContext));

  Future<PcscResult<List<String>>> listReaders(int hContext) =>
      _executor.execute(_factory.listReaders(hContext));

  Future<SCardResult> cancel(int hContext) =>
      _executor.execute(_factory.cancel(hContext));

  Future<PcscResult<List<int>>> getAttrib(int hCard, int dwAttrId) =>
      _executor.execute(_factory.getAttrib(hCard, dwAttrId));

  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) =>
      _executor.execute(_factory.setAttrib(hCard, dwAttrId, pbAttr));
}


// --- Native Utilities ---
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