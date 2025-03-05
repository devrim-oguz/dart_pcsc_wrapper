import 'package:tuple/tuple.dart';
import 'package:pcsc_wrapper/common/pcsc_structs.dart';

abstract class IPCSCBindings {

  Tuple2<SCardResult, SCardContext> establishContext(int dwScope);

  SCardResult releaseContext(int hContext);

  SCardResult isValidContext(int hContext);

  Tuple2<SCardResult, SCardHandle> connect(int hContext, String szReader, int dwShareMode, int dwPreferredProtocols);

  Tuple2<SCardResult, SCardHandle> reconnect(int hCard, int dwShareMode, int dwPreferredProtocols, int dwInitialization);

  SCardResult disconnect(int hCard, int dwDisposition);

  SCardResult beginTransaction(int hCard);

  SCardResult endTransaction(int hCard, int dwDisposition);

  Tuple2<SCardResult, SCardStatus> status(int hCard);

  Tuple2<SCardResult, List<SCardReaderState>> getStatusChange(int hContext, int dwTimeout, List<SCardReaderState> rgReaderStates);

  Tuple2<SCardResult, List<int>> control(int hCard, int dwControlCode, List<int> pbSendBuffer);

  Tuple2<SCardResult, List<int>> transmit(int hCard, int pioSendPci, List<int> pbSendBuffer);

  Tuple2<SCardResult, List<String>> listReaderGroups(int hContext);

  Tuple2<SCardResult, List<String>> listReaders(int hContext);

  SCardResult cancel(int hContext);

  Tuple2<SCardResult, List<int>> getAttrib(int hCard, int dwAttrId);

  SCardResult setAttrib(int hCard, int dwAttrId, List<int> pbAttr);
}