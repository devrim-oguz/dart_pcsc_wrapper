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

  Future<PcscResult<SCardContext>> establishContext(int scope) =>
      _bindings.establishContext(scope);

  Future<SCardResult> releaseContext(SCardContext context) =>
      _bindings.releaseContext(context.hContext);

  Future<SCardResult> isValidContext(int hContext) =>
      _bindings.isValidContext(hContext);

  Future<PcscResult<List<String>>> listReaders(int hContext) =>
      _bindings.listReaders(hContext);

  Future<PcscResult<SCardHandle>> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols) =>
      _bindings.connect(hContext, szReader, dwShareMode, dwPreferredProtocols);

  Future<PcscResult<SCardHandle>> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization) =>
      _bindings.reconnect(hCard, dwShareMode, dwPreferredProtocols, dwInitialization);

  Future<SCardResult> disconnect(int hCard, int dwDisposition) =>
      _bindings.disconnect(hCard, dwDisposition);

  Future<SCardResult> beginTransaction(int hCard) =>
      _bindings.beginTransaction(hCard);

  Future<SCardResult> endTransaction(int hCard, int dwDisposition) =>
      _bindings.endTransaction(hCard, dwDisposition);

  Future<PcscResult<SCardStatus>> status(int hCard) =>
      _bindings.status(hCard);

  Future<PcscResult<List<SCardReaderState>>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates) =>
      _bindings.getStatusChange(hContext, dwTimeout, rgReaderStates);

  Future<PcscResult<List<int>>> control(int hCard, int dwControlCode, List<int> pbSendBuffer) =>
      _bindings.control(hCard, dwControlCode, pbSendBuffer);

  Future<PcscResult<List<int>>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer) =>
      _bindings.transmit(hCard, pioSendPci, pbSendBuffer);

  Future<PcscResult<List<String>>> listReaderGroups(int hContext) =>
      _bindings.listReaderGroups(hContext);

  Future<SCardResult> cancel(int hContext) =>
      _bindings.cancel(hContext);

  Future<PcscResult<List<int>>> getAttrib(int hCard, int dwAttrId) =>
      _bindings.getAttrib(hCard, dwAttrId);

  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr) =>
      _bindings.setAttrib(hCard, dwAttrId, pbAttr);
}