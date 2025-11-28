import 'package:tuple/tuple.dart';
import 'package:pcsc_wrapper/common/pcsc_structs.dart';

abstract class IPCSCBindings {

  Future<Tuple2<SCardResult, SCardContext>> establishContext(int dwScope);

  Future<SCardResult> releaseContext(int hContext);

  Future<SCardResult> isValidContext(int hContext);

  Future<Tuple2<SCardResult, SCardHandle>> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols);

  Future<Tuple2<SCardResult, SCardHandle>> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization);

  Future<SCardResult> disconnect(int hCard, int dwDisposition);

  Future<SCardResult> beginTransaction(int hCard);

  Future<SCardResult> endTransaction(int hCard, int dwDisposition);

  Future<Tuple2<SCardResult, SCardStatus>> status(int hCard);

  Future<Tuple2<SCardResult, List<SCardReaderState>>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates);

  Future<Tuple2<SCardResult, List<int>>> control(int hCard, int dwControlCode, List<int> pbSendBuffer);

  Future<Tuple2<SCardResult, List<int>>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer);

  Future<Tuple2<SCardResult, List<String>>> listReaderGroups(int hContext);

  Future<Tuple2<SCardResult, List<String>>> listReaders(int hContext);

  Future<SCardResult> cancel(int hContext);

  Future<Tuple2<SCardResult, List<int>>> getAttrib(int hCard, int dwAttrId);

  Future<SCardResult> setAttrib(int hCard, int dwAttrId, List<int> pbAttr);
}