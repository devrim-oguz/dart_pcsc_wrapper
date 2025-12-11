//  static final _pcsc = ffi.DynamicLibrary.open("/System/Library/Frameworks/PCSC.framework/Versions/Current/PCSC");

import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:pcsc_wrapper/common/pcsc_bindings_base.dart';
import 'package:pcsc_wrapper/bindings/generated/winscard_macos.dart';
import 'package:pcsc_wrapper/common/pcsc_types.dart';

// --- MacOS Bindings ---

class MacOSBindings extends PcscBindings {
  @override
  void Function(SendPort) get isolateEntryPoint => _MacOSIsolateEntry;

  @override
  PcscCommandFactory createCommandFactory() => MacOSCommandFactory();
}

// --- MacOS Context ---

class MacOSPcscContext extends PcscContext {
  final WinscardMacOS winscard;
  final ffi.Pointer<SCARD_IO_REQUEST> scardT0Pci;
  final ffi.Pointer<SCARD_IO_REQUEST> scardT1Pci;
  final ffi.Pointer<Never> nullptr = ffi.Pointer.fromAddress(0);

  MacOSPcscContext(this.winscard, this.scardT0Pci, this.scardT1Pci);
}

// --- MacOS Isolate Entry ---

void _MacOSIsolateEntry(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  final pcsc = ffi.DynamicLibrary.open('libpcsclite.so.1');
  final winscard = WinscardMacOS(pcsc);

  final scardT0Pci = calloc<SCARD_IO_REQUEST>();
  final scardT1Pci = calloc<SCARD_IO_REQUEST>();

  scardT0Pci.ref.cbPciLength = winscard.g_rgSCardT0Pci.cbPciLength;
  scardT0Pci.ref.dwProtocol = winscard.g_rgSCardT0Pci.dwProtocol;
  scardT1Pci.ref.cbPciLength = winscard.g_rgSCardT1Pci.cbPciLength;
  scardT1Pci.ref.dwProtocol = winscard.g_rgSCardT1Pci.dwProtocol;

  final context = MacOSPcscContext(winscard, scardT0Pci, scardT1Pci);

  receivePort.listen((message) {
    if (message is CommandMessage) {
      try {
        final result = message.command.execute(context);
        message.replyPort.send(result);
      } catch (e) {
        message.replyPort.send(e);
      }
    }
  });
}

// --- MacOS Command Factory ---

class MacOSCommandFactory implements PcscCommandFactory {
  @override
  PcscCommand<EstablishContextResult> establishContext(int dwScope) =>
      _EstablishContext(dwScope);

  @override
  PcscCommand<SCardResult> releaseContext(int hContext) =>
      _ReleaseContext(hContext);

  @override
  PcscCommand<SCardResult> isValidContext(int hContext) =>
      _IsValidContext(hContext);

  @override
  PcscCommand<ConnectResult> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) =>
      _Connect(hContext, szReader, dwShareMode, dwPreferredProtocols);

  @override
  PcscCommand<ReconnectResult> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) =>
      _Reconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization);

  @override
  PcscCommand<SCardResult> disconnect(int hCard, int dwDisposition) =>
      _Disconnect(hCard, dwDisposition);

  @override
  PcscCommand<SCardResult> beginTransaction(int hCard) =>
      _BeginTransaction(hCard);

  @override
  PcscCommand<SCardResult> endTransaction(int hCard, int dwDisposition) =>
      _EndTransaction(hCard, dwDisposition);

  @override
  PcscCommand<StatusResult> status(int hCard) =>
      _Status(hCard);

  @override
  PcscCommand<GetStatusChangeResult> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> states) =>
      _GetStatusChange(hContext, dwTimeout, states);

  @override
  PcscCommand<ControlResult> control(int hCard, int dwControlCode, List<int> pbSendBuffer) =>
      _Control(hCard, dwControlCode, pbSendBuffer);

  @override
  PcscCommand<TransmitResult> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) =>
      _Transmit(hCard, pioSendPci, pbSendBuffer);

  @override
  PcscCommand<ListReaderGroupsResult> listReaderGroups(int hContext) =>
      _ListReaderGroups(hContext);

  @override
  PcscCommand<ListReadersResult> listReaders(int hContext) =>
      _ListReaders(hContext);

  @override
  PcscCommand<SCardResult> cancel(int hContext) =>
      _Cancel(hContext);

  @override
  PcscCommand<GetAttribResult> getAttrib(int hCard, int dwAttrId) =>
      _GetAttrib(hCard, dwAttrId);

  @override
  PcscCommand<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) =>
      _SetAttrib(hCard, dwAttrId, pbAttr);
}

// --- MacOS Commands (private, platform-specific) ---

MacOSPcscContext _getContext(PcscContext ctx) => ctx as MacOSPcscContext;

class _EstablishContext extends PcscCommand<EstablishContextResult> {
  final int dwScope;
  _EstablishContext(this.dwScope);

  @override
  EstablishContextResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final phContext = calloc<SCARDCONTEXT>();
    try {
      final result = context.winscard.SCardEstablishContext(dwScope, context.nullptr, context.nullptr, phContext);
      return EstablishContextResult(SCardResult(result), SCardContext(phContext.value));
    } finally {
      calloc.free(phContext);
    }
  }
}

class _ReleaseContext extends PcscCommand<SCardResult> {
  final int hContext;
  _ReleaseContext(this.hContext);

  @override
  SCardResult execute(PcscContext ctx) =>
      SCardResult(_getContext(ctx).winscard.SCardReleaseContext(hContext));
}

class _IsValidContext extends PcscCommand<SCardResult> {
  final int hContext;
  _IsValidContext(this.hContext);

  @override
  SCardResult execute(PcscContext ctx) =>
      SCardResult(_getContext(ctx).winscard.SCardIsValidContext(hContext));
}

class _Connect extends PcscCommand<ConnectResult> {
  final int hContext;
  final String szReader;
  final int dwShareMode;
  final int dwPreferredProtocols;

  _Connect(this.hContext, this.szReader, this.dwShareMode, this.dwPreferredProtocols);

  @override
  ConnectResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final readerNamePtr = NativeUtils.allocateString(szReader);
    final cardHandlePtr = calloc<SCARDHANDLE>();
    final protocolPtr = calloc<DWORD>();
    try {
      final result = context.winscard.SCardConnect(hContext, readerNamePtr, dwShareMode, dwPreferredProtocols, cardHandlePtr, protocolPtr);
      return ConnectResult(SCardResult(result), SCardHandle(cardHandlePtr.value, protocolPtr.value));
    } finally {
      calloc.free(readerNamePtr);
      calloc.free(cardHandlePtr);
      calloc.free(protocolPtr);
    }
  }
}

class _Reconnect extends PcscCommand<ReconnectResult> {
  final int hCard;
  final int dwShareMode;
  final int dwPreferredProtocols;
  final int dwInitialization;

  _Reconnect(this.hCard, this.dwShareMode, this.dwPreferredProtocols, this.dwInitialization);

  @override
  ReconnectResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final protocolPtr = calloc<DWORD>();
    try {
      final result = context.winscard.SCardReconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization, protocolPtr);
      return ReconnectResult(SCardResult(result), SCardHandle(hCard, protocolPtr.value));
    } finally {
      calloc.free(protocolPtr);
    }
  }
}

class _Disconnect extends PcscCommand<SCardResult> {
  final int hCard;
  final int dwDisposition;
  _Disconnect(this.hCard, this.dwDisposition);

  @override
  SCardResult execute(PcscContext ctx) =>
      SCardResult(_getContext(ctx).winscard.SCardDisconnect(hCard, dwDisposition));
}

class _BeginTransaction extends PcscCommand<SCardResult> {
  final int hCard;
  _BeginTransaction(this.hCard);

  @override
  SCardResult execute(PcscContext ctx) =>
      SCardResult(_getContext(ctx).winscard.SCardBeginTransaction(hCard));
}

class _EndTransaction extends PcscCommand<SCardResult> {
  final int hCard;
  final int dwDisposition;
  _EndTransaction(this.hCard, this.dwDisposition);

  @override
  SCardResult execute(PcscContext ctx) =>
      SCardResult(_getContext(ctx).winscard.SCardEndTransaction(hCard, dwDisposition));
}

class _Status extends PcscCommand<StatusResult> {
  final int hCard;
  _Status(this.hCard);

  @override
  StatusResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final statePtr = calloc<DWORD>();
    final protocolPtr = calloc<DWORD>();
    final readerNameLenPtr = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final readerNameBuffer = calloc<ffi.Char>(MAX_BUFFER_SIZE);
    final atrLenPtr = calloc<DWORD>()..value = MAX_ATR_SIZE;
    final atrBuffer = calloc<BYTE>(MAX_ATR_SIZE);

    try {
      final retValue = context.winscard.SCardStatus(hCard, readerNameBuffer, readerNameLenPtr, statePtr, protocolPtr, atrBuffer, atrLenPtr);
      final result = SCardResult(retValue);
      if (!result.isSuccess) return StatusResult(result, SCardStatus("", 0, 0, []));

      return StatusResult(result, SCardStatus(
        NativeUtils.convertString(readerNameBuffer),
        statePtr.value,
        protocolPtr.value,
        NativeUtils.convertBytes(atrBuffer.cast<ffi.Uint8>(), atrLenPtr.value)
      ));
    } finally {
      calloc.free(statePtr);
      calloc.free(protocolPtr);
      calloc.free(readerNameLenPtr);
      calloc.free(readerNameBuffer);
      calloc.free(atrLenPtr);
      calloc.free(atrBuffer);
    }
  }
}

class _GetStatusChange extends PcscCommand<GetStatusChangeResult> {
  final int hContext;
  final int dwTimeout;
  final List<SCardReaderState> states;

  _GetStatusChange(this.hContext, this.dwTimeout, this.states);

  @override
  GetStatusChangeResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final nativeNames = states.map((state) => NativeUtils.allocateString(state.szReader)).toList();
    final nativeStates = calloc<SCARD_READERSTATE>(states.length);

    try {
      for (int i = 0; i < states.length; i++) {
        nativeStates[i].szReader = nativeNames[i];
        nativeStates[i].dwCurrentState = states[i].dwCurrentState;
        nativeStates[i].dwEventState = 0;
        nativeStates[i].cbAtr = MAX_ATR_SIZE;
        for (int j = 0; j < states[i].rgbAtr.length && j < MAX_ATR_SIZE; j++) {
          nativeStates[i].rgbAtr[j] = states[i].rgbAtr[j];
        }
      }

      final retValue = context.winscard.SCardGetStatusChange(hContext, dwTimeout, nativeStates, states.length);
      final result = SCardResult(retValue);

      if (!result.isSuccess) return GetStatusChangeResult(result, []);

      final updatedStates = <SCardReaderState>[];
      for (int i = 0; i < states.length; i++) {
        final atrLength = nativeStates[i].cbAtr;
        final atrBytes = <int>[];
        for (int j = 0; j < atrLength && j < MAX_ATR_SIZE; j++) {
          atrBytes.add(nativeStates[i].rgbAtr[j]);
        }
        updatedStates.add(SCardReaderState(
          NativeUtils.convertString(nativeStates[i].szReader),
          nativeStates[i].dwCurrentState,
          nativeStates[i].dwEventState,
          atrBytes
        ));
      }
      return GetStatusChangeResult(result, updatedStates);
    } finally {
      for (var namePtr in nativeNames) calloc.free(namePtr);
      calloc.free(nativeStates);
    }
  }
}

class _Control extends PcscCommand<ControlResult> {
  final int hCard;
  final int dwControlCode;
  final List<int> pbSendBuffer;

  _Control(this.hCard, this.dwControlCode, this.pbSendBuffer);

  @override
  ControlResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final sendBuffer = NativeUtils.allocateBytes(pbSendBuffer);
    final receiveBuffer = calloc<ffi.Uint8>(MAX_BUFFER_SIZE);
    final bytesReturnedPtr = calloc<DWORD>();

    try {
      final retValue = context.winscard.SCardControl(hCard, dwControlCode, sendBuffer.cast<ffi.Void>(), pbSendBuffer.length, receiveBuffer.cast<ffi.Void>(), MAX_BUFFER_SIZE, bytesReturnedPtr);
      final result = SCardResult(retValue);
      if (!result.isSuccess) return ControlResult(result, []);
      return ControlResult(result, NativeUtils.convertBytes(receiveBuffer, bytesReturnedPtr.value));
    } finally {
      calloc.free(sendBuffer);
      calloc.free(receiveBuffer);
      calloc.free(bytesReturnedPtr);
    }
  }
}

class _Transmit extends PcscCommand<TransmitResult> {
  final int hCard;
  final int pioSendPci;
  final List<int> pbSendBuffer;

  _Transmit(this.hCard, this.pioSendPci, this.pbSendBuffer);

  @override
  TransmitResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final sendBuffer = NativeUtils.allocateBytes(pbSendBuffer);
    final receiveBuffer = calloc<BYTE>(MAX_BUFFER_SIZE);
    final bytesReturnedPtr = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    
    ffi.Pointer<SCARD_IO_REQUEST> protocolControlInfo;
    if (pioSendPci == SCARD_PROTOCOL_T0) protocolControlInfo = context.scardT0Pci;
    else if (pioSendPci == SCARD_PROTOCOL_T1) protocolControlInfo = context.scardT1Pci;
    else protocolControlInfo = context.nullptr.cast();

    try {
      final retValue = context.winscard.SCardTransmit(hCard, protocolControlInfo, sendBuffer.cast<BYTE>(), pbSendBuffer.length, context.nullptr.cast(), receiveBuffer, bytesReturnedPtr);
      final result = SCardResult(retValue);
      if (!result.isSuccess) return TransmitResult(result, []);
      return TransmitResult(result, NativeUtils.convertBytes(receiveBuffer.cast<ffi.Uint8>(), bytesReturnedPtr.value));
    } finally {
      calloc.free(sendBuffer);
      calloc.free(receiveBuffer);
      calloc.free(bytesReturnedPtr);
    }
  }
}

class _ListReaderGroups extends PcscCommand<ListReaderGroupsResult> {
  final int hContext;
  _ListReaderGroups(this.hContext);

  @override
  ListReaderGroupsResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final bufferLenPtr = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final multiStringBuffer = calloc<ffi.Char>(MAX_BUFFER_SIZE);
    try {
      final retValue = context.winscard.SCardListReaderGroups(hContext, multiStringBuffer, bufferLenPtr);
      final result = SCardResult(retValue);
      if (!result.isSuccess) return ListReaderGroupsResult(result, []);
      return ListReaderGroupsResult(result, NativeUtils.multiStringToDart(multiStringBuffer.cast<Utf8>()).toList());
    } finally {
      calloc.free(multiStringBuffer);
      calloc.free(bufferLenPtr);
    }
  }
}

class _ListReaders extends PcscCommand<ListReadersResult> {
  final int hContext;
  _ListReaders(this.hContext);

  @override
  ListReadersResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final bufferLenPtr = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final multiStringBuffer = calloc<ffi.Char>(MAX_BUFFER_SIZE);
    try {
      final retValue = context.winscard.SCardListReaders(hContext, context.nullptr, multiStringBuffer, bufferLenPtr);
      final result = SCardResult(retValue);
      if (!result.isSuccess) return ListReadersResult(result, []);
      return ListReadersResult(result, NativeUtils.multiStringToDart(multiStringBuffer.cast<Utf8>()).toList());
    } finally {
      calloc.free(multiStringBuffer);
      calloc.free(bufferLenPtr);
    }
  }
}

class _Cancel extends PcscCommand<SCardResult> {
  final int hContext;
  _Cancel(this.hContext);

  @override
  SCardResult execute(PcscContext ctx) =>
      SCardResult(_getContext(ctx).winscard.SCardCancel(hContext));
}

class _GetAttrib extends PcscCommand<GetAttribResult> {
  final int hCard;
  final int dwAttrId;
  _GetAttrib(this.hCard, this.dwAttrId);

  @override
  GetAttribResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final bufferLenPtr = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final attrBuffer = calloc<BYTE>(MAX_BUFFER_SIZE);
    try {
      final retValue = context.winscard.SCardGetAttrib(hCard, dwAttrId, attrBuffer, bufferLenPtr);
      final result = SCardResult(retValue);
      if (!result.isSuccess) return GetAttribResult(result, []);
      return GetAttribResult(result, NativeUtils.convertBytes(attrBuffer.cast<ffi.Uint8>(), bufferLenPtr.value));
    } finally {
      calloc.free(attrBuffer);
      calloc.free(bufferLenPtr);
    }
  }
}

class _SetAttrib extends PcscCommand<SCardResult> {
  final int hCard;
  final int dwAttrId;
  final List<int> pbAttr;
  _SetAttrib(this.hCard, this.dwAttrId, this.pbAttr);

  @override
  SCardResult execute(PcscContext ctx) {
    final context = _getContext(ctx);
    final attrBuffer = NativeUtils.allocateBytes(pbAttr);
    try {
      return SCardResult(context.winscard.SCardSetAttrib(hCard, dwAttrId, attrBuffer.cast<BYTE>(), pbAttr.length));
    } finally {
      calloc.free(attrBuffer);
    }
  }
}


