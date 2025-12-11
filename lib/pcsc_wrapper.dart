library pcsc_wrapper;

import 'dart:io';

import 'package:pcsc_wrapper/common/pcsc_bindings_interface.dart';
import 'package:pcsc_wrapper/bindings/linux_bindings.dart';
import 'package:pcsc_wrapper/common/pcsc_types.dart';

export 'common/pcsc_types.dart';
export 'common/pcsc_constants.dart';

class PCSCWrapper {
  late IPCSCBindings _bindings;

  PCSCWrapper() {
    //Attach the bindings based on the operating system
    if( Platform.isLinux ) {
      _bindings = LinuxBindings();
    }
    /*else if( Platform.isMacOS ) {
      _bindings = MacOSBindings();
    }
    else if( Platform.isWindows ) {
      _bindings = WindowsBindings();
    }*/
    else {
      throw Exception("Unsupported operating system");
    }
  }

  Future<EstablishContextResult> establishContext(int scope) async {
    return await _bindings.establishContext(scope);
  }

  Future<SCardResult> releaseContext(SCardContext context) async {
    return await _bindings.releaseContext(context.hContext);
  }

  Future<SCardResult> isValidContext(int hContext) async {
    return await _bindings.isValidContext(hContext);
  }

  Future<ListReadersResult> listReaders(int hContext) async {
    return await _bindings.listReaders(hContext);
  }

  Future<ConnectResult> connect( int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) async {
    return await _bindings.connect(hContext, szReader, dwShareMode, dwPreferredProtocols);
  }

  Future<ReconnectResult> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) async {
    return await _bindings.reconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization);
  }

  Future<SCardResult> disconnect(int hCard, int dwDisposition) async {
    return await _bindings.disconnect(hCard, dwDisposition);
  }

  Future<SCardResult> beginTransaction(int hCard) async {
    return await _bindings.beginTransaction(hCard);
  }

  Future<SCardResult> endTransaction(int hCard, int dwDisposition) async {
    return await _bindings.endTransaction(hCard, dwDisposition);
  }

  Future<StatusResult> status(int hCard) async {
    return await _bindings.status(hCard);
  }

  Future<GetStatusChangeResult> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) async {
    return await _bindings.getStatusChange(hContext, dwTimeout, rgReaderStates);
  }

  Future<ControlResult> control(int hCard, int dwControlCode, List<int> pbSendBuffer) async {
    return await _bindings.control(hCard, dwControlCode, pbSendBuffer);
  }

  Future<TransmitResult> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) async {
    return await _bindings.transmit(hCard, pioSendPci, pbSendBuffer);
  }

  Future<ListReaderGroupsResult> listReaderGroups(int hContext) async {
    return await _bindings.listReaderGroups(hContext);
  }

  Future<SCardResult> cancel(int hContext) async {
    return await _bindings.cancel(hContext);
  }

  Future<GetAttribResult> getAttrib(int hCard, int dwAttrId) async {
    return await _bindings.getAttrib(hCard, dwAttrId);
  }

  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) async {
    return await _bindings.setAttrib(hCard, dwAttrId, pbAttr);
  }
}