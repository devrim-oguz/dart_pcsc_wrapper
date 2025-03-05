library pcsc_wrapper;

import 'dart:io';

import 'package:pcsc_wrapper/bindings/binding_interface.dart';
import 'package:pcsc_wrapper/bindings/linux_bindings.dart';
import 'package:pcsc_wrapper/bindings/macos_bindings.dart';
import 'package:pcsc_wrapper/common/pcsc_structs.dart';
import 'package:tuple/tuple.dart';

export 'common/pcsc_structs.dart';
export 'common/pcsc_constants.dart';

class PCSCWrapper {
  late IPCSCBindings _bindings;

  PCSCWrapper() {
    //Attach the bindings based on the operating system
    if( Platform.isLinux ) {
      _bindings = LinuxBindings();
    }
    else if( Platform.isMacOS ) {
      _bindings = MacOSBindings();
    }
    else if( Platform.isWindows ) {
      throw Exception("Windows platform is not supported by this library");
    }
    else {
      throw Exception("Unsupported operating system");
    }
  }

  Future<SCardContext> establishContext(int scope) async {
    Tuple2<SCardResult, SCardContext> result = _bindings.establishContext(scope);
    _checkError(result.item1);
    return result.item2;
  }

  Future<void> releaseContext(SCardContext context) async {
    SCardResult result = _bindings.releaseContext(context.hContext);
    _checkError(result);
  }

  Future<bool> isValidContext(int hContext) async {
    SCardResult result = _bindings.isValidContext(hContext);
    return result.isSuccess;
  }

  Future<List<String>> listReaders(int hContext) async {
    Tuple2<SCardResult, List<String>> result = _bindings.listReaders(hContext);
    _checkError(result.item1);
    return result.item2;
  }

  Future<SCardHandle> connect( int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) async {
    Tuple2<SCardResult, SCardHandle> result = _bindings.connect(hContext, szReader, dwShareMode, dwPreferredProtocols);
    _checkError(result.item1);
    return result.item2;
  }

  Future<SCardHandle> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) async {
    Tuple2<SCardResult, SCardHandle> result = _bindings.reconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization);
    _checkError(result.item1);
    return result.item2;
  }

  Future<void> disconnect(int hCard, int dwDisposition) async {
    SCardResult result = _bindings.disconnect(hCard, dwDisposition);
    _checkError(result);
  }

  Future<void> beginTransaction(int hCard) async {
    SCardResult result = _bindings.beginTransaction(hCard);
    _checkError(result);
  }

  Future<void> endTransaction(int hCard, int dwDisposition) async {
    SCardResult result = _bindings.endTransaction(hCard, dwDisposition);
    _checkError(result);
  }

  Future<SCardStatus> status(int hCard) async {
    Tuple2<SCardResult, SCardStatus> result = _bindings.status(hCard);
    _checkError(result.item1);
    return result.item2;
  }

  Future<List<SCardReaderState>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) async {
    Tuple2<SCardResult, List<SCardReaderState>> result = _bindings.getStatusChange(hContext, dwTimeout, rgReaderStates);
    _checkError(result.item1);
    return result.item2;
  }

  Future<List<int>> control(int hCard, int dwControlCode, List<int> pbSendBuffer) async {
    Tuple2<SCardResult, List<int>> result = _bindings.control(hCard, dwControlCode, pbSendBuffer);
    _checkError(result.item1);
    return result.item2;
  }

  Future<List<int>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) async {
    Tuple2<SCardResult, List<int>> result = _bindings.transmit(hCard, pioSendPci, pbSendBuffer);
    _checkError(result.item1);
    return result.item2;
  }

  Future<List<String>> listReaderGroups(int hContext) async {
    Tuple2<SCardResult, List<String>> result = _bindings.listReaderGroups(hContext);
    _checkError(result.item1);
    return result.item2;
  }

  Future<void> cancel(int hContext) async {
    SCardResult result = _bindings.cancel(hContext);
    _checkError(result);
  }

  Future<List<int>> getAttrib(int hCard, int dwAttrId) async {
    Tuple2<SCardResult, List<int>> result = _bindings.getAttrib(hCard, dwAttrId);
    _checkError(result.item1);
    return result.item2;
  }

  Future<void> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) async {
    SCardResult result = _bindings.setAttrib(hCard, dwAttrId, pbAttr);
    _checkError(result);
  }

  void _checkError(SCardResult result) {
    if (!result.isSuccess) {
      throw Exception(result.message);
    }
  }

}