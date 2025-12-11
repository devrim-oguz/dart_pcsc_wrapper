import 'package:pcsc_wrapper/common/pcsc_types.dart';

abstract class IPCSCBindings {

  Future<EstablishContextResult> establishContext(int dwScope);

  Future<SCardResult> releaseContext(int hContext);

  Future<SCardResult> isValidContext(int hContext);

  Future<ConnectResult> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols);

  Future<ReconnectResult> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization);

  Future<SCardResult> disconnect(int hCard, int dwDisposition);

  Future<SCardResult> beginTransaction(int hCard);

  Future<SCardResult> endTransaction(int hCard, int dwDisposition);

  Future<StatusResult> status(int hCard);

  Future<GetStatusChangeResult> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates);

  Future<ControlResult> control(int hCard, int dwControlCode, List<int> pbSendBuffer);

  Future<TransmitResult> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer);

  Future<ListReaderGroupsResult> listReaderGroups(int hContext);

  Future<ListReadersResult> listReaders(int hContext);

  Future<SCardResult> cancel(int hContext);

  Future<GetAttribResult> getAttrib(int hCard, int dwAttrId);

  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr);
}