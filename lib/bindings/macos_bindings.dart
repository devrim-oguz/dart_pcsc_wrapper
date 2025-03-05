import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pcsc_wrapper/bindings/binding_interface.dart';
import 'package:tuple/tuple.dart';
import 'package:pcsc_wrapper/bindings/generated/winscard_macos.dart';
import 'package:pcsc_wrapper/common/pcsc_structs.dart';

class MacOSBindings implements IPCSCBindings {
  static final _pcsc = ffi.DynamicLibrary.open("/System/Library/Frameworks/PCSC.framework/Versions/Current/PCSC");
  static final WinscardMacOS _winscard = WinscardMacOS(_pcsc);
  static final ffi.Pointer<Never> _nullptr = ffi.Pointer.fromAddress(0);

  final _scardT0Pci = calloc<SCARD_IO_REQUEST>();
  final _scardT1Pci = calloc<SCARD_IO_REQUEST>();

  MacOSBindings() {
    _scardT0Pci.ref.cbPciLength = _winscard.g_rgSCardT0Pci.cbPciLength;
    _scardT0Pci.ref.dwProtocol = _winscard.g_rgSCardT0Pci.dwProtocol;

    _scardT1Pci.ref.cbPciLength = _winscard.g_rgSCardT1Pci.cbPciLength;
    _scardT1Pci.ref.dwProtocol = _winscard.g_rgSCardT1Pci.dwProtocol;
  }

  dispose() {
    calloc.free(_scardT0Pci);
    calloc.free(_scardT1Pci);
  }

  @override
  Tuple2<SCardResult, SCardContext> establishContext(int dwScope) {
    var phContext = calloc<SCARDCONTEXT>();

    try {
      var response = _winscard.SCardEstablishContext(dwScope, _nullptr, _nullptr, phContext);
      var result = SCardResult(response);

      return Tuple2(result, SCardContext(phContext.value));
    }
    finally {
      calloc.free(phContext);
    }
  }

  @override
  SCardResult releaseContext(int hContext) {
    return SCardResult(_winscard.SCardReleaseContext(hContext));
  }

  @override
  SCardResult isValidContext(int hContext) {
    return SCardResult(_winscard.SCardIsValidContext(hContext));
  }

  @override
  Tuple2<SCardResult, SCardHandle> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) {
    final ffi.Pointer<ffi.Char> nativeReaderName = _allocateNativeString(szReader);
    final phCard = calloc<SCARDHANDLE>();
    final pdwActiveProtocol = calloc<DWORD>();

    try {
      var response = _winscard.SCardConnect(hContext, nativeReaderName, dwShareMode, dwPreferredProtocols, phCard, pdwActiveProtocol);
      return Tuple2(SCardResult(response), SCardHandle(phCard.value, pdwActiveProtocol.value));
    }
    finally {
      calloc.free(nativeReaderName);
      calloc.free(phCard);
      calloc.free(pdwActiveProtocol);
    }
  }

  @override
  Tuple2<SCardResult, SCardHandle> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) {
    final pdwActiveProtocol = calloc<DWORD>();

    try {
      var response = _winscard.SCardReconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization, pdwActiveProtocol);
      return Tuple2(SCardResult(response), SCardHandle(hCard, pdwActiveProtocol.value));
    }
    finally {
      calloc.free(pdwActiveProtocol);
    }
  }

  @override
  SCardResult disconnect(int hCard, int dwDisposition) {
    return SCardResult(_winscard.SCardDisconnect(hCard, dwDisposition));
  }

  @override
  SCardResult beginTransaction(int hCard) {
    return SCardResult(_winscard.SCardBeginTransaction(hCard));
  }

  @override
  SCardResult endTransaction(int hCard, int dwDisposition) {
    return SCardResult(_winscard.SCardEndTransaction(hCard, dwDisposition));
  }

  @override
  Tuple2<SCardResult, SCardStatus> status(int hCard) {
    final pdwState = calloc<DWORD>();
    final pdwProtocol = calloc<DWORD>();

    final pcchReaderLen = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final mszReaderName = calloc<ffi.Char>(pcchReaderLen.value);

    final pcbAtrLen = calloc<DWORD>()..value = MAX_ATR_SIZE;
    final pbAtr = calloc<BYTE>(pcbAtrLen.value);

    try {
      var response = _winscard.SCardStatus(hCard, mszReaderName, pcchReaderLen, pdwState, pdwProtocol, pbAtr, pcbAtrLen);
      var result = SCardResult(response);

      if( !result.isSuccess ) {
        return Tuple2(result, SCardStatus("", 0, 0, []));
      }

      var nameString = _convertNativeString(mszReaderName);
      var attributeList = _convertNativeBytes(pbAtr, pcbAtrLen.value);

      return Tuple2(SCardResult(response), SCardStatus(nameString, pdwState.value, pdwProtocol.value, attributeList));
    }
    finally {
      calloc.free(mszReaderName);
      calloc.free(pcchReaderLen);
      calloc.free(pdwState);
      calloc.free(pdwProtocol);
      calloc.free(pbAtr);
      calloc.free(pcbAtrLen);
    }
  }

  @override 
  Tuple2<SCardResult, List<SCardReaderState>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) {
    // Define the maximum size of the ATR buffer.
    final atrBufferSize = MAX_ATR_SIZE;

    // Create a list of native string pointers for each reader name.
    final List<ffi.Pointer<ffi.Char>> nativeReaderNames = rgReaderStates.map((state) => _allocateNativeString(state.szReader)).toList();

    // Allocate memory for an array of SCARD_READERSTATE structures.
    final nativeReaderStates = calloc<SCARD_READERSTATE>(rgReaderStates.length);

    try {
      // Copy each Dart reader state into its native counterpart.
      for (int i = 0; i < rgReaderStates.length; i++) {
        final state = rgReaderStates[i];
        nativeReaderStates[i].szReader = nativeReaderNames[i];
        nativeReaderStates[i].pvUserData = ffi.nullptr;
        nativeReaderStates[i].dwCurrentState = state.dwCurrentState;
        nativeReaderStates[i].dwEventState = 0;
        nativeReaderStates[i].cbAtr = atrBufferSize;

        // Copy any initial ATR bytes if provided (up to the available length and buffer size).
        for (int j = 0; j < state.rgbAtr.length && j < atrBufferSize; j++) {
          nativeReaderStates[i].rgbAtr[j] = state.rgbAtr[j];
        }
      }

      // Call the native SCardGetStatusChange() function.
      // This call will block until a reader event occurs or the timeout expires.
      final response = _winscard.SCardGetStatusChange( hContext, dwTimeout, nativeReaderStates, rgReaderStates.length );
      final result = SCardResult(response);

      // If the call failed, return immediately with an empty state list.
      if (!result.isSuccess) {
        return Tuple2(result, []);
      }

      // Build the updated list of SCardReaderState objects based on the native structure values.
      List<SCardReaderState> updatedStates = [];

      for (int i = 0; i < rgReaderStates.length; i++) {
        // The native structure's cbAtr should now contain the actual ATR length.
        final int actualAtrLength = nativeReaderStates[i].cbAtr;
        List<int> atrBytes = [];

        // Copy only the valid ATR bytes.
        for (int j = 0; j < actualAtrLength && j < atrBufferSize; j++) {
          atrBytes.add(nativeReaderStates[i].rgbAtr[j]);
        }
        
        // Convert the native reader name back into a Dart string.
        final readerName = _convertNativeString(nativeReaderStates[i].szReader);

        // Create a new SCardReaderState with updated values from the native structure.
        updatedStates.add( SCardReaderState( readerName, nativeReaderStates[i].dwCurrentState, nativeReaderStates[i].dwEventState, atrBytes ));
      }

      // Return the result code along with the updated list of reader states.
      return Tuple2(result, updatedStates);
    } 
    finally {
      // Free each native string allocated for the reader names.
      for (final ptr in nativeReaderNames) {
        calloc.free(ptr);
      }
      // Free the allocated array of SCARD_READERSTATE.
      calloc.free(nativeReaderStates);
    }
  }

  @override
  Tuple2<SCardResult, List<int>> control(int hCard, int dwControlCode, List<int> pbSendBuffer) {
    final sendBuffer = _allocateNativeBytes(pbSendBuffer);
    final recvBuffer = calloc<ffi.Uint8>(MAX_BUFFER_SIZE);
    final bytesReturned = calloc<DWORD>();

    try {
      //Call the native function
      var response = _winscard.SCardControl(hCard, dwControlCode, sendBuffer.cast<ffi.Void>(), pbSendBuffer.length, recvBuffer.cast<ffi.Void>(), MAX_BUFFER_SIZE, bytesReturned);
      var result = SCardResult(response);

      //Check if the call was successful
      if( !result.isSuccess ) {
        return Tuple2(result, []);
      }

      //Create a list of bytes
      List<int> byteList = _convertNativeBytes(recvBuffer.cast<BYTE>(), bytesReturned.value);

      //Return the result
      return Tuple2(result, byteList);
    }
    finally {
      //Free the buffers
      calloc.free(sendBuffer);
      calloc.free(recvBuffer);
      calloc.free(bytesReturned);
    }
  }

  @override
  Tuple2<SCardResult, List<int>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) {
    final sendBuffer = _allocateNativeBytes(pbSendBuffer);
    final recvBuffer = calloc<BYTE>(MAX_BUFFER_SIZE);
    final bytesReturned = calloc<DWORD>();
    bytesReturned.value = MAX_BUFFER_SIZE;

    try {
      //Call the native function
      var response = _winscard.SCardTransmit(hCard, _getPciProtocol(pioSendPci), sendBuffer, pbSendBuffer.length, _nullptr.cast(), recvBuffer, bytesReturned);
      var result = SCardResult(response);

      //Check if the call was successful
      if( !result.isSuccess ) {
        return Tuple2(result, []);
      }

      //Create a list of bytes
      List<int> byteList = _convertNativeBytes(recvBuffer, bytesReturned.value);

      //Return the result
      return Tuple2(result, byteList);
    }
    finally {
      //Free the buffers
      calloc.free(sendBuffer);
      calloc.free(recvBuffer);
      calloc.free(bytesReturned);
    }
  }

  @override
  Tuple2<SCardResult, List<String>> listReaderGroups(int hContext) {
    final pcchGroups = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final mszGroups = calloc<ffi.Char>(pcchGroups.value);

    try {
      var response = _winscard.SCardListReaderGroups(hContext, mszGroups, pcchGroups);
      var result = SCardResult(response);

      if( !result.isSuccess ) {
        return Tuple2(result, []);
      }

      var groupList = _convertNativeStringArray(mszGroups, pcchGroups.value);

      return Tuple2(result, groupList);
    }
    finally {
      calloc.free(mszGroups);
      calloc.free(pcchGroups);
    }
  }

  @override
  Tuple2<SCardResult, List<String>> listReaders(int hContext) {
    final pcchReaders = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final mszReaders = calloc<ffi.Char>(pcchReaders.value);

    try {
      var response = _winscard.SCardListReaders(hContext, _nullptr, mszReaders, pcchReaders);
      var result = SCardResult(response);

      if( !result.isSuccess ) {
        return Tuple2(result, []);
      }

      var readerList = _convertNativeStringArray(mszReaders, pcchReaders.value);

      return Tuple2(result, readerList);
    }
    finally {
      calloc.free(mszReaders);
      calloc.free(pcchReaders);
    }
  }

  @override
  SCardResult cancel(int hContext) {
    return SCardResult(_winscard.SCardCancel(hContext));
  }

  @override
  Tuple2<SCardResult, List<int>> getAttrib(int hCard, int dwAttrId) {
    final pcbAttrLen = calloc<DWORD>()..value = MAX_BUFFER_SIZE;
    final pbAttr = calloc<BYTE>(pcbAttrLen.value);

    try {
      var response = _winscard.SCardGetAttrib(hCard, dwAttrId, pbAttr, pcbAttrLen);
      var result = SCardResult(response);

      if( !result.isSuccess ) {
        return Tuple2(result, []);
      }

      var attributeList = _convertNativeBytes(pbAttr, pcbAttrLen.value);

      return Tuple2(result, attributeList);
    }
    finally {
      calloc.free(pbAttr);
      calloc.free(pcbAttrLen);
    }
  }

  @override
  SCardResult setAttrib(int hCard, int dwAttrId, List<int> pbAttr) {
    final pbAttrBuffer = _allocateNativeBytes(pbAttr);

    try {
      return SCardResult(_winscard.SCardSetAttrib(hCard, dwAttrId, pbAttrBuffer, pbAttr.length));
    }
    finally {
      calloc.free(pbAttrBuffer);
    }
  }


  //Helper Functions///////////////////////////////////////////////////////////////////////////////
  Int8List _asInt8List(ffi.Pointer<ffi.Int8> p, int length) {
    Int8List result = Int8List(length);
    for (int i = 0; i < length; i++) {
      result[i] = p[i];
    }
    return result;
  }

  Uint8List _asUint8List(ffi.Pointer<ffi.Uint8> p, int length) {
    Uint8List result = Uint8List(length);
    for (int i = 0; i < length; i++) {
      result[i] = p[i];
    }
    return result;
  }

  ffi.Pointer<ffi.Char> _allocateNativeString(String inputString) {
    return inputString.toNativeUtf8(allocator: calloc).cast();
  }

  String _convertNativeString(ffi.Pointer<ffi.Char> nativeString) {
    return nativeString.cast<Utf8>().toDartString();
  }

  List<String> _convertNativeStringArray(ffi.Pointer<ffi.Char> nativeString, int inputLength) {
    List<int> list = _asInt8List(nativeString.cast(), inputLength);
    List<String> result = List.empty(growable: true);
    int prevPos = 0;

    while (prevPos < list.length) {
      int pos = list.indexOf(0, prevPos);
      if (pos == -1) {
        pos = list.length;
      }
      if (prevPos != pos) {
        String s = String.fromCharCodes(
            Uint8List.fromList(list.sublist(prevPos, pos)));
        result.add(s);
      }
      prevPos = pos + 1;
    }

    return result;
  }

  ffi.Pointer<BYTE> _allocateNativeBytes(List<int> inputBytes) {
    var result = calloc<ffi.Uint8>(inputBytes.length);
    var bufferView = result.asTypedList(inputBytes.length);
    bufferView.setAll(0, inputBytes);

    return result.cast();
  }

  List<int> _convertNativeBytes(ffi.Pointer<BYTE> nativeBytes, int length) {
    return nativeBytes.cast<ffi.Uint8>().asTypedList(length).toList();
  }

  ffi.Pointer<SCARD_IO_REQUEST> _getPciProtocol(int protocolNumber) {
    switch (protocolNumber) {
      case SCARD_PROTOCOL_T0:
        return _scardT0Pci;
      case SCARD_PROTOCOL_T1:
        return _scardT1Pci;
      default:
        return _nullptr.cast();
    }
  }

}
