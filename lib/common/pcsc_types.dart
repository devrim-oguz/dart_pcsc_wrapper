import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:pcsc_wrapper/common/pcsc_constants.dart';

//Function Return Types
class SCardResult {
  final int code;
  String get message => PcscConstants.returnCodeToString(code);
  bool get isSuccess => code == PcscConstants.SCARD_S_SUCCESS;

  SCardResult(this.code);
}

class EstablishContextResult {
  final SCardResult result;
  final SCardContext context;

  EstablishContextResult(this.result, this.context);
}

class ConnectResult {
  final SCardResult result;
  final SCardHandle handle;

  ConnectResult(this.result, this.handle);
}

class ReconnectResult {
  final SCardResult result;
  final SCardHandle handle;

  ReconnectResult(this.result, this.handle);
}

class StatusResult {
  final SCardResult result;
  final SCardStatus status;

  StatusResult(this.result, this.status);
}

class GetStatusChangeResult {
  final SCardResult result;
  final List<SCardReaderState> readerStates;

  GetStatusChangeResult(this.result, this.readerStates);
}

class ControlResult {
  final SCardResult result;
  final List<int> response;

  ControlResult(this.result, this.response);
}

class TransmitResult {
  final SCardResult result;
  final List<int> response;

  TransmitResult(this.result, this.response);
}

class ListReaderGroupsResult {
  final SCardResult result;
  final List<String> groups;

  ListReaderGroupsResult(this.result, this.groups);
}

class ListReadersResult {
  final SCardResult result;
  final List<String> readers;

  ListReadersResult(this.result, this.readers);
}

class GetAttribResult {
  final SCardResult result;
  final List<int> attrib;

  GetAttribResult(this.result, this.attrib);
}

//Library Specific Types
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