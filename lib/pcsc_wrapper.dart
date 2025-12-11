library pcsc_wrapper;

import 'dart:io';

import 'package:pcsc_wrapper/common/pcsc_types.dart';
import 'package:pcsc_wrapper/common/pcsc_bindings_base.dart';
import 'package:pcsc_wrapper/bindings/linux_bindings.dart';
import 'package:pcsc_wrapper/bindings/macos_bindings.dart';

export 'common/pcsc_constants.dart';
export 'common/pcsc_types.dart';

class PCSCWrapper {
  late PcscBindings _bindings;

  PCSCWrapper() {
    if (Platform.isLinux) {
      _bindings = LinuxBindings();
    }
    else if (Platform.isMacOS) {
      _bindings = MacOSBindings();
    }
    /*else if (Platform.isWindows) {
      _bindings = WindowsBindings();
    }*/
    else {
      throw Exception("Unsupported operating system");
    }
  }

  void dispose() => _bindings.dispose();

  Future<EstablishContextResult> establishContext(int scope) =>
      _bindings.establishContext(scope);

  Future<SCardResult> releaseContext(SCardContext context) =>
      _bindings.releaseContext(context.hContext);

  Future<SCardResult> isValidContext(int hContext) =>
      _bindings.isValidContext(hContext);

  Future<ListReadersResult> listReaders(int hContext) =>
      _bindings.listReaders(hContext);

  Future<ConnectResult> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) =>
      _bindings.connect(hContext, szReader, dwShareMode, dwPreferredProtocols);

  Future<ReconnectResult> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) =>
      _bindings.reconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization);

  Future<SCardResult> disconnect(int hCard, int dwDisposition) =>
      _bindings.disconnect(hCard, dwDisposition);

  Future<SCardResult> beginTransaction(int hCard) =>
      _bindings.beginTransaction(hCard);

  Future<SCardResult> endTransaction(int hCard, int dwDisposition) =>
      _bindings.endTransaction(hCard, dwDisposition);

  Future<StatusResult> status(int hCard) =>
      _bindings.status(hCard);

  Future<GetStatusChangeResult> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) =>
      _bindings.getStatusChange(hContext, dwTimeout, rgReaderStates);

  Future<ControlResult> control(int hCard, int dwControlCode, List<int> pbSendBuffer) =>
      _bindings.control(hCard, dwControlCode, pbSendBuffer);

  Future<TransmitResult> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) =>
      _bindings.transmit(hCard, pioSendPci, pbSendBuffer);

  Future<ListReaderGroupsResult> listReaderGroups(int hContext) =>
      _bindings.listReaderGroups(hContext);

  Future<SCardResult> cancel(int hContext) =>
      _bindings.cancel(hContext);

  Future<GetAttribResult> getAttrib(int hCard, int dwAttrId) =>
      _bindings.getAttrib(hCard, dwAttrId);

  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) =>
      _bindings.setAttrib(hCard, dwAttrId, pbAttr);
}