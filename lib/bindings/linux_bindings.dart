import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:pcsc_wrapper/bindings/binding_interface.dart';
import 'package:tuple/tuple.dart';
import 'package:pcsc_wrapper/bindings/generated/winscard_linux.dart';
import 'package:pcsc_wrapper/common/pcsc_structs.dart';

class LinuxBindings implements IPCSCBindings {
  Isolate? _isolate;
  SendPort? _commandPort;
  final Completer<void> _isolateReady = Completer<void>();

  static final Finalizer<Isolate> _finalizer = Finalizer((isolate) {
    isolate.kill(priority: Isolate.immediate);
  });

  LinuxBindings() {
    _initIsolate();
  }

  Future<void> _initIsolate() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    _finalizer.attach(this, _isolate!, detach: this);
    _commandPort = await receivePort.first as SendPort;
    _isolateReady.complete();
  }

  Future<T> _send<T>(PcscCommand<T> command) async {
    await _isolateReady.future;
    final responsePort = ReceivePort();
    _commandPort!.send(_CommandMessage(command, responsePort.sendPort));
    final result = await responsePort.first;
    if (result is Exception) throw result;
    return result as T;
  }

  dispose() {
    _finalizer.detach(this);
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  @override
  Future<Tuple2<SCardResult, SCardContext>> establishContext(int dwScope) {
    return _send(EstablishContextCommand(dwScope));
  }

  @override
  Future<SCardResult> releaseContext(int hContext) {
    return _send(ReleaseContextCommand(hContext));
  }

  @override
  Future<SCardResult> isValidContext(int hContext) {
    return _send(IsValidContextCommand(hContext));
  }

  @override
  Future<Tuple2<SCardResult, SCardHandle>> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) {
    return _send(ConnectCommand(hContext, szReader, dwShareMode, dwPreferredProtocols));
  }

  @override
  Future<Tuple2<SCardResult, SCardHandle>> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) {
    return _send(ReconnectCommand(hCard, dwShareMode, dwPreferredProtocols, dwInitialization));
  }

  @override
  Future<SCardResult> disconnect(int hCard, int dwDisposition) {
    return _send(DisconnectCommand(hCard, dwDisposition));
  }

  @override
  Future<SCardResult> beginTransaction(int hCard) {
    return _send(BeginTransactionCommand(hCard));
  }

  @override
  Future<SCardResult> endTransaction(int hCard, int dwDisposition) {
    return _send(EndTransactionCommand(hCard, dwDisposition));
  }

  @override
  Future<Tuple2<SCardResult, SCardStatus>> status(int hCard) {
    return _send(StatusCommand(hCard));
  }

  @override
  Future<Tuple2<SCardResult, List<SCardReaderState>>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) {
    return _send(GetStatusChangeCommand(hContext, dwTimeout, rgReaderStates));
  }

  @override
  Future<Tuple2<SCardResult, List<int>>> control(int hCard, int dwControlCode, List<int> pbSendBuffer) {
    return _send(ControlCommand(hCard, dwControlCode, pbSendBuffer));
  }

  @override
  Future<Tuple2<SCardResult, List<int>>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) {
    return _send(TransmitCommand(hCard, pioSendPci, pbSendBuffer));
  }

  @override
  Future<Tuple2<SCardResult, List<String>>> listReaderGroups(int hContext) {
    return _send(ListReaderGroupsCommand(hContext));
  }

  @override
  Future<Tuple2<SCardResult, List<String>>> listReaders(int hContext) {
    return _send(ListReadersCommand(hContext));
  }

  @override
  Future<SCardResult> cancel(int hContext) {
    return _send(CancelCommand(hContext));
  }

  @override
  Future<Tuple2<SCardResult, List<int>>> getAttrib(int hCard, int dwAttrId) {
    return _send(GetAttribCommand(hCard, dwAttrId));
  }

  @override
  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) {
    return _send(SetAttribCommand(hCard, dwAttrId, pbAttr));
  }
}

// --- Isolate & Command Infrastructure ---

class _CommandMessage {
  final PcscCommand command;
  final SendPort replyPort;
  _CommandMessage(this.command, this.replyPort);
}

class _PcscContext {
  final WinscardLinux winscard;
  final ffi.Pointer<SCARD_IO_REQUEST> scardT0Pci;
  final ffi.Pointer<SCARD_IO_REQUEST> scardT1Pci;
  final ffi.Pointer<Never> nullptr = ffi.Pointer.fromAddress(0);

  _PcscContext(this.winscard, this.scardT0Pci, this.scardT1Pci);
}

void _isolateEntry(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  // Load library once within the isolate
  final pcsc = ffi.DynamicLibrary.open('libpcsclite.so.1');
  final winscard = WinscardLinux(pcsc);

  final scardT0Pci = calloc<SCARD_IO_REQUEST>();
  final scardT1Pci = calloc<SCARD_IO_REQUEST>();

  scardT0Pci.ref.cbPciLength = winscard.g_rgSCardT0Pci.cbPciLength;
  scardT0Pci.ref.dwProtocol = winscard.g_rgSCardT0Pci.dwProtocol;
  scardT1Pci.ref.cbPciLength = winscard.g_rgSCardT1Pci.cbPciLength;
  scardT1Pci.ref.dwProtocol = winscard.g_rgSCardT1Pci.dwProtocol;

  final context = _PcscContext(winscard, scardT0Pci, scardT1Pci);

  receivePort.listen((message) {
    if (message is _CommandMessage) {
      try {
        final result = message.command.execute(context);
        message.replyPort.send(result);
      } 
      catch (e) {
        message.replyPort.send(e);
      }
    }
  });
}

// --- Commands ---

abstract class PcscCommand<T> {
  T execute(_PcscContext ctx);
}

class EstablishContextCommand extends PcscCommand<Tuple2<SCardResult, SCardContext>> {
  final int dwScope;
  EstablishContextCommand(this.dwScope);

  @override
  Tuple2<SCardResult, SCardContext> execute(_PcscContext ctx) {
    final phContext = calloc<SCARDCONTEXT>();
    try {
      final ret = ctx.winscard.SCardEstablishContext(dwScope, ctx.nullptr, ctx.nullptr, phContext);
      return Tuple2(SCardResult(ret), SCardContext(phContext.value));
    } finally {
      calloc.free(phContext);
    }
  }
}

class ReleaseContextCommand extends PcscCommand<SCardResult> {
  final int hContext;
  ReleaseContextCommand(this.hContext);
  @override
  SCardResult execute(_PcscContext ctx) => SCardResult(ctx.winscard.SCardReleaseContext(hContext));
}

class IsValidContextCommand extends PcscCommand<SCardResult> {
  final int hContext;
  IsValidContextCommand(this.hContext);
  @override
  SCardResult execute(_PcscContext ctx) => SCardResult(ctx.winscard.SCardIsValidContext(hContext));
}

class ConnectCommand extends PcscCommand<Tuple2<SCardResult, SCardHandle>> {
  final int hContext;
  final String szReader;
  final int dwShareMode;
  final int dwPreferredProtocols;

  ConnectCommand(this.hContext, this.szReader, this.dwShareMode, this.dwPreferredProtocols);

  @override
  Tuple2<SCardResult, SCardHandle> execute(_PcscContext ctx) {
    final pReader = _NativeUtils.allocateString(szReader);
    final phCard = calloc<SCARDHANDLE>();
    final pdwProtocol = calloc<DWORD>();
    try {
      final ret = ctx.winscard.SCardConnect(hContext, pReader, dwShareMode, dwPreferredProtocols, phCard, pdwProtocol);
      return Tuple2(SCardResult(ret), SCardHandle(phCard.value, pdwProtocol.value));
    } finally {
      calloc.free(pReader);
      calloc.free(phCard);
      calloc.free(pdwProtocol);
    }
  }
}

class ReconnectCommand extends PcscCommand<Tuple2<SCardResult, SCardHandle>> {
  final int hCard;
  final int dwShareMode;
  final int dwPreferredProtocols;
  final int dwInitialization;

  ReconnectCommand(this.hCard, this.dwShareMode, this.dwPreferredProtocols, this.dwInitialization);

  @override
  Tuple2<SCardResult, SCardHandle> execute(_PcscContext ctx) {
    final pdwProtocol = calloc<DWORD>();
    try {
      final ret = ctx.winscard.SCardReconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization, pdwProtocol);
      return Tuple2(SCardResult(ret), SCardHandle(hCard, pdwProtocol.value));
    } finally {
      calloc.free(pdwProtocol);
    }
  }
}

class DisconnectCommand extends PcscCommand<SCardResult> {
  final int hCard;
  final int dwDisposition;
  DisconnectCommand(this.hCard, this.dwDisposition);
  @override
  SCardResult execute(_PcscContext ctx) => SCardResult(ctx.winscard.SCardDisconnect(hCard, dwDisposition));
}

class BeginTransactionCommand extends PcscCommand<SCardResult> {
  final int hCard;
  BeginTransactionCommand(this.hCard);
  @override
  SCardResult execute(_PcscContext ctx) => SCardResult(ctx.winscard.SCardBeginTransaction(hCard));
}

class EndTransactionCommand extends PcscCommand<SCardResult> {
  final int hCard;
  final int dwDisposition;
  EndTransactionCommand(this.hCard, this.dwDisposition);
  @override
  SCardResult execute(_PcscContext ctx) => SCardResult(ctx.winscard.SCardEndTransaction(hCard, dwDisposition));
}

class StatusCommand extends PcscCommand<Tuple2<SCardResult, SCardStatus>> {
  final int hCard;
  StatusCommand(this.hCard);

  @override
  Tuple2<SCardResult, SCardStatus> execute(_PcscContext ctx) {
    final pdwState = calloc<DWORD>();
    final pdwProtocol = calloc<DWORD>();
    final pcchReaderLen = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final mszReaderName = calloc<ffi.Char>(MAX_BUFFER_SIZE);
    final pcbAtrLen = calloc<DWORD>()..value = MAX_ATR_SIZE;
    final pbAtr = calloc<BYTE>(MAX_ATR_SIZE);

    try {
      final ret = ctx.winscard.SCardStatus(hCard, mszReaderName, pcchReaderLen, pdwState, pdwProtocol, pbAtr, pcbAtrLen);
      final result = SCardResult(ret);
      if (!result.isSuccess) return Tuple2(result, SCardStatus("", 0, 0, []));

      return Tuple2(result, SCardStatus(
        _NativeUtils.convertString(mszReaderName),
        pdwState.value,
        pdwProtocol.value,
        _NativeUtils.convertBytes(pbAtr.cast<ffi.Uint8>(), pcbAtrLen.value)
      ));
    } finally {
      calloc.free(pdwState);
      calloc.free(pdwProtocol);
      calloc.free(pcchReaderLen);
      calloc.free(mszReaderName);
      calloc.free(pcbAtrLen);
      calloc.free(pbAtr);
    }
  }
}

class GetStatusChangeCommand extends PcscCommand<Tuple2<SCardResult, List<SCardReaderState>>> {
  final int hContext;
  final int dwTimeout;
  final List<SCardReaderState> states;

  GetStatusChangeCommand(this.hContext, this.dwTimeout, this.states);

  @override
  Tuple2<SCardResult, List<SCardReaderState>> execute(_PcscContext ctx) {
    final nativeNames = states.map((s) => _NativeUtils.allocateString(s.szReader)).toList();
    final nativeStates = calloc<SCARD_READERSTATE>(states.length);

    try {
      for (int i = 0; i < states.length; i++) {
        nativeStates[i].szReader = nativeNames[i];
        nativeStates[i].dwCurrentState = states[i].dwCurrentState;
        nativeStates[i].dwEventState = 0;
        nativeStates[i].cbAtr = MAX_ATR_SIZE;
        // Copy existing ATR if any
        for (int j = 0; j < states[i].rgbAtr.length && j < MAX_ATR_SIZE; j++) {
          nativeStates[i].rgbAtr[j] = states[i].rgbAtr[j];
        }
      }

      final ret = ctx.winscard.SCardGetStatusChange(hContext, dwTimeout, nativeStates, states.length);
      final result = SCardResult(ret);

      if (!result.isSuccess) return Tuple2(result, []);

      final updated = <SCardReaderState>[];
      for (int i = 0; i < states.length; i++) {
        final atrLen = nativeStates[i].cbAtr;
        final atr = <int>[];
        for (int j = 0; j < atrLen && j < MAX_ATR_SIZE; j++) {
          atr.add(nativeStates[i].rgbAtr[j]);
        }
        updated.add(SCardReaderState(
          _NativeUtils.convertString(nativeStates[i].szReader),
          nativeStates[i].dwCurrentState,
          nativeStates[i].dwEventState,
          atr
        ));
      }
      return Tuple2(result, updated);
    } finally {
      for (var ptr in nativeNames) calloc.free(ptr);
      calloc.free(nativeStates);
    }
  }
}

class ControlCommand extends PcscCommand<Tuple2<SCardResult, List<int>>> {
  final int hCard;
  final int dwControlCode;
  final List<int> pbSendBuffer;

  ControlCommand(this.hCard, this.dwControlCode, this.pbSendBuffer);

  @override
  Tuple2<SCardResult, List<int>> execute(_PcscContext ctx) {
    final sendBuf = _NativeUtils.allocateBytes(pbSendBuffer);
    final recvBuf = calloc<ffi.Uint8>(MAX_BUFFER_SIZE);
    final bytesRet = calloc<DWORD>();

    try {
      final ret = ctx.winscard.SCardControl(hCard, dwControlCode, sendBuf.cast<ffi.Void>(), pbSendBuffer.length, recvBuf.cast<ffi.Void>(), MAX_BUFFER_SIZE, bytesRet);
      final result = SCardResult(ret);
      if (!result.isSuccess) return Tuple2(result, []);
      return Tuple2(result, _NativeUtils.convertBytes(recvBuf, bytesRet.value));
    } finally {
      calloc.free(sendBuf);
      calloc.free(recvBuf);
      calloc.free(bytesRet);
    }
  }
}

class TransmitCommand extends PcscCommand<Tuple2<SCardResult, List<int>>> {
  final int hCard;
  final int pioSendPci;
  final List<int> pbSendBuffer;

  TransmitCommand(this.hCard, this.pioSendPci, this.pbSendBuffer);

  @override
  Tuple2<SCardResult, List<int>> execute(_PcscContext ctx) {
    final sendBuf = _NativeUtils.allocateBytes(pbSendBuffer);
    final recvBuf = calloc<BYTE>(MAX_BUFFER_SIZE);
    final bytesRet = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    
    ffi.Pointer<SCARD_IO_REQUEST> pci;
    if (pioSendPci == SCARD_PROTOCOL_T0) pci = ctx.scardT0Pci;
    else if (pioSendPci == SCARD_PROTOCOL_T1) pci = ctx.scardT1Pci;
    else pci = ctx.nullptr.cast();

    try {
      final ret = ctx.winscard.SCardTransmit(hCard, pci, sendBuf.cast<BYTE>(), pbSendBuffer.length, ctx.nullptr.cast(), recvBuf, bytesRet);
      final result = SCardResult(ret);
      if (!result.isSuccess) return Tuple2(result, []);
      return Tuple2(result, _NativeUtils.convertBytes(recvBuf.cast<ffi.Uint8>(), bytesRet.value));
    } finally {
      calloc.free(sendBuf);
      calloc.free(recvBuf);
      calloc.free(bytesRet);
    }
  }
}

class ListReaderGroupsCommand extends PcscCommand<Tuple2<SCardResult, List<String>>> {
  final int hContext;
  ListReaderGroupsCommand(this.hContext);

  @override
  Tuple2<SCardResult, List<String>> execute(_PcscContext ctx) {
    final pcch = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final msz = calloc<ffi.Char>(MAX_BUFFER_SIZE);
    try {
      final ret = ctx.winscard.SCardListReaderGroups(hContext, msz, pcch);
      final result = SCardResult(ret);
      if (!result.isSuccess) return Tuple2(result, []);
      return Tuple2(result, _NativeUtils.convertStringArray(msz, pcch.value));
    } finally {
      calloc.free(msz);
      calloc.free(pcch);
    }
  }
}

class ListReadersCommand extends PcscCommand<Tuple2<SCardResult, List<String>>> {
  final int hContext;
  ListReadersCommand(this.hContext);

  @override
  Tuple2<SCardResult, List<String>> execute(_PcscContext ctx) {
    final pcch = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final msz = calloc<ffi.Char>(MAX_BUFFER_SIZE);
    try {
      final ret = ctx.winscard.SCardListReaders(hContext, ctx.nullptr, msz, pcch);
      final result = SCardResult(ret);
      if (!result.isSuccess) return Tuple2(result, []);
      return Tuple2(result, _NativeUtils.convertStringArray(msz, pcch.value));
    } finally {
      calloc.free(msz);
      calloc.free(pcch);
    }
  }
}

class CancelCommand extends PcscCommand<SCardResult> {
  final int hContext;
  CancelCommand(this.hContext);
  @override
  SCardResult execute(_PcscContext ctx) => SCardResult(ctx.winscard.SCardCancel(hContext));
}

class GetAttribCommand extends PcscCommand<Tuple2<SCardResult, List<int>>> {
  final int hCard;
  final int dwAttrId;
  GetAttribCommand(this.hCard, this.dwAttrId);

  @override
  Tuple2<SCardResult, List<int>> execute(_PcscContext ctx) {
    final pcb = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final pb = calloc<BYTE>(MAX_BUFFER_SIZE);
    try {
      final ret = ctx.winscard.SCardGetAttrib(hCard, dwAttrId, pb, pcb);
      final result = SCardResult(ret);
      if (!result.isSuccess) return Tuple2(result, []);
      return Tuple2(result, _NativeUtils.convertBytes(pb.cast<ffi.Uint8>(), pcb.value));
    } finally {
      calloc.free(pb);
      calloc.free(pcb);
    }
  }
}

class SetAttribCommand extends PcscCommand<SCardResult> {
  final int hCard;
  final int dwAttrId;
  final List<int> pbAttr;
  SetAttribCommand(this.hCard, this.dwAttrId, this.pbAttr);

  @override
  SCardResult execute(_PcscContext ctx) {
    final pb = _NativeUtils.allocateBytes(pbAttr);
    try {
      return SCardResult(ctx.winscard.SCardSetAttrib(hCard, dwAttrId, pb.cast<BYTE>(), pbAttr.length));
    } finally {
      calloc.free(pb);
    }
  }
}


// --- Native Utilities ---

class _NativeUtils {
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

  static List<String> convertStringArray(ffi.Pointer<ffi.Char> ptr, int length) {
    final list = ptr.cast<ffi.Int8>().asTypedList(length);
    final result = <String>[];
    int start = 0;
    while (start < list.length) {
      int end = list.indexOf(0, start);
      if (end == -1) break;
      if (start != end) {
        result.add(String.fromCharCodes(list.sublist(start, end)));
      }
      start = end + 1;
    }
    return result;
  }
}