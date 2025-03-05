import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:pcsc_wrapper/common/pcsc_constants.dart';

class SCardResult {
  final int code;
  String get message => PcscConstants.returnCodeToString(code);
  bool get isSuccess => code == PcscConstants.SCARD_S_SUCCESS;

  SCardResult(this.code);
}

class SCardContext {
  final int hContext;
  SCardContext(this.hContext);
}

class SCardHandle {
  final int hCard;
  final int dwActiveProtocol;

  SCardHandle(this.hCard, this.dwActiveProtocol);
}

class SCardStatus {
  final String szReaderName;
  final int dwState;
  final int dwProtocol;
  final List<int> bAtr;

  SCardStatus(this.szReaderName, this.dwState, this.dwProtocol, this.bAtr);
}

class SCardReaderState {
  final String szReader;
  final int dwCurrentState;
  final int dwEventState;
  final List<int> rgbAtr;

  SCardReaderState(this.szReader, this.dwCurrentState, this.dwEventState, this.rgbAtr);
}

class SCardReaderResponse {
  final List<Uint8> bytes;

  SCardReaderResponse(this.bytes);
}

Iterable<String> multiStringToDart(Pointer<Utf8> multiString) sync* {
  while (multiString.cast<Int8>().value != 0) {
    final length = multiString.length;
    yield multiString.toDartString(length: length);
    multiString = Pointer.fromAddress(multiString.address + length + 1);
  }
}