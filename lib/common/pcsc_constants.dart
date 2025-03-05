class PcscConstants {
  // Limits
  static const int PCSCLITE_MAX_READERS_CONTEXTS = 16;
  static const int MAX_READERNAME = 128;
  static const int MAX_BUFFER_SIZE = 264;

  static const int MAX_BUFFER_SIZE_EXTENDED = 65548;

  // Scope
  static const int CARD_SCOPE_USER = 0x0000;
  static const int CARD_SCOPE_TERMINAL = 0x0001;
  static const int CARD_SCOPE_SYSTEM = 0x0002;
  // Limits
  static const int MAX_ATR_SIZE = 33;
  static const int MAX_ATR_SIZE_PADDING = 3;
  // States (Internal)
  static const int SCARD_UNKNOWN = 0x0001;
  static const int SCARD_ABSENT = 0x0002;
  static const int SCARD_PRESENT = 0x0004;
  static const int SCARD_SWALLOWED = 0x0008;
  static const int SCARD_POWERED = 0x0010;
  static const int SCARD_NEGOTIABLE = 0x0020;
  static const int SCARD_SPECIFIC = 0x0040;
  // States (GetStatusChange)
  static const int SCARD_STATE_UNAWARE = 0x0000;
  static const int SCARD_STATE_IGNORE = 0x0001;
  static const int SCARD_STATE_CHANGED = 0x0002;
  static const int SCARD_STATE_UNKNOWN = 0x0004;
  static const int SCARD_STATE_UNAVAILABLE = 0x0008;
  static const int SCARD_STATE_EMPTY = 0x0010;
  static const int SCARD_STATE_PRESENT = 0x0020;
  static const int SCARD_STATE_ATRMATCH = 0x0040;
  static const int SCARD_STATE_EXCLUSIVE = 0x0080;
  static const int SCARD_STATE_INUSE = 0x0100;
  static const int SCARD_STATE_MUTE = 0x0200;
  static const int SCARD_STATE_UNPOWERED = 0x0400;
  // Protocols
  static const int SCARD_PROTOCOL_UNDEFINED = 0x0000;
  static const int SCARD_PROTOCOL_T0 = 0x0001;
  static const int SCARD_PROTOCOL_T1 = 0x0002;
  static const int SCARD_PROTOCOL_RAW = 0x0004;
  static const int SCARD_PROTOCOL_T15 = 0x0008;
  static const int SCARD_PROTOCOL_ANY = (SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1);
  // Sharing
  static const int SCARD_SHARE_EXCLUSIVE = 0x0001;
  static const int SCARD_SHARE_SHARED = 0x0002;
  static const int SCARD_SHARE_DIRECT = 0x0003;
  // Disconnect
  static const int SCARD_LEAVE_CARD = 0x0000;
  static const int SCARD_RESET_CARD = 0x0001;
  static const int SCARD_UNPOWER_CARD = 0x0002;
  static const int SCARD_EJECT_CARD = 0x0003;
  // Errors
  static const int SCARD_S_SUCCESS = 0x00000000;
  static const int SCARD_F_INTERNAL_ERROR = 0x80100001;
  static const int SCARD_E_CANCELLED = 0x80100002;
  static const int SCARD_E_INVALID_HANDLE = 0x80100003;
  static const int SCARD_E_INVALID_PARAMETER = 0x80100004;
  static const int SCARD_E_INVALID_TARGET = 0x80100005;
  static const int SCARD_E_NO_MEMORY = 0x80100006;
  static const int SCARD_F_WAITED_TOO_LONG = 0x80100007;
  static const int SCARD_E_INSUFFICIENT_BUFFER = 0x80100008;
  static const int SCARD_E_UNKNOWN_READER = 0x80100009;
  static const int SCARD_E_TIMEOUT = 0x8010000A;
  static const int SCARD_E_SHARING_VIOLATION = 0x8010000B;
  static const int SCARD_E_NO_SMARTCARD = 0x8010000C;
  static const int SCARD_E_UNKNOWN_CARD = 0x8010000D;
  static const int SCARD_E_CANT_DISPOSE = 0x8010000E;
  static const int SCARD_E_PROTO_MISMATCH = 0x8010000F;
  static const int SCARD_E_NOT_READY = 0x80100010;
  static const int SCARD_E_INVALID_VALUE = 0x80100011;
  static const int SCARD_E_SYSTEM_CANCELLED = 0x80100012;
  static const int SCARD_F_COMM_ERROR = 0x80100013;
  static const int SCARD_F_UNKNOWN_ERROR = 0x80100014;
  static const int SCARD_E_INVALID_ATR = 0x80100015;
  static const int SCARD_E_NOT_TRANSACTED = 0x80100016;
  static const int SCARD_E_READER_UNAVAILABLE = 0x80100017;
  static const int SCARD_P_SHUTDOWN = 0x80100018;
  static const int SCARD_E_PCI_TOO_SMALL = 0x80100019;
  static const int SCARD_E_READER_UNSUPPORTED = 0x8010001A;
  static const int SCARD_E_DUPLICATE_READER = 0x8010001B;
  static const int SCARD_E_CARD_UNSUPPORTED = 0x8010001C;
  static const int SCARD_E_NO_SERVICE = 0x8010001D;
  static const int SCARD_E_SERVICE_STOPPED = 0x8010001E;
  static const int SCARD_E_UNEXPECTED = 0x8010001F;
  static const int SCARD_E_ICC_INSTALLATION = 0x80100020;
  static const int SCARD_E_ICC_CREATEORDER = 0x80100021;
  static const int SCARD_E_UNSUPPORTED_FEATURE = 0x80100022;
  static const int SCARD_E_DIR_NOT_FOUND = 0x80100023;
  static const int SCARD_E_FILE_NOT_FOUND = 0x80100024;
  static const int SCARD_E_NO_DIR = 0x80100025;
  static const int SCARD_E_NO_FILE = 0x80100026;
  static const int SCARD_E_NO_ACCESS = 0x80100027;
  static const int SCARD_E_WRITE_TOO_MANY = 0x80100028;
  static const int SCARD_E_BAD_SEEK = 0x80100029;
  static const int SCARD_E_INVALID_CHV = 0x8010002A;
  static const int SCARD_E_UNKNOWN_RES_MNG = 0x8010002B;
  static const int SCARD_E_NO_SUCH_CERTIFICATE = 0x8010002C;
  static const int SCARD_E_CERTIFICATE_UNAVAILABLE = 0x8010002D;
  static const int SCARD_E_NO_READERS_AVAILABLE = 0x8010002E;
  static const int SCARD_E_COMM_DATA_LOST = 0x8010002F;
  static const int SCARD_E_NO_KEY_CONTAINER = 0x80100030;
  static const int SCARD_E_SERVER_TOO_BUSY = 0x80100031;
  static const int SCARD_W_UNSUPPORTED_CARD = 0x80100065;
  static const int SCARD_W_UNRESPONSIVE_CARD = 0x80100066;
  static const int SCARD_W_UNPOWERED_CARD = 0x80100067;
  static const int SCARD_W_RESET_CARD = 0x80100068;
  static const int SCARD_W_REMOVED_CARD = 0x80100069;
  static const int SCARD_W_SECURITY_VIOLATION = 0x8010006A;
  static const int SCARD_W_WRONG_CHV = 0x8010006B;
  static const int SCARD_W_CHV_BLOCKED = 0x8010006C;
  static const int SCARD_W_EOF = 0x8010006D;
  static const int SCARD_W_CANCELLED_BY_USER = 0x8010006E;
  static const int SCARD_W_CARD_NOT_AUTHENTICATED = 0x8010006F;
  // Others
  static const int SCARD_INFINITE = 0xFFFFFFFF;
  // Attributes
  static const int SCARD_CLASS_ICC_STATE = 9;
  static const int SCARD_ATTR_ATR_STRING =
      (SCARD_CLASS_ICC_STATE << 16 | 0x0303);


  static const Map<int, String> returnCodeMap = {
    SCARD_S_SUCCESS: 'SCARD_S_SUCCESS: The operation was successful.',
    SCARD_F_INTERNAL_ERROR: 'SCARD_F_INTERNAL_ERROR: Internal system error.',
    SCARD_E_CANCELLED: 'SCARD_E_CANCELLED: The operation was canceled.',
    SCARD_E_INVALID_HANDLE: 'SCARD_E_INVALID_HANDLE: The handle is invalid.',
    SCARD_E_INVALID_PARAMETER: 'SCARD_E_INVALID_PARAMETER: One or more parameters are invalid.',
    SCARD_E_INVALID_TARGET: 'SCARD_E_INVALID_TARGET: Invalid target, possibly no device found.',
    SCARD_E_NO_MEMORY: 'SCARD_E_NO_MEMORY: Not enough memory available.',
    SCARD_F_WAITED_TOO_LONG: 'SCARD_F_WAITED_TOO_LONG: Wait time exceeded.',
    SCARD_E_INSUFFICIENT_BUFFER: 'SCARD_E_INSUFFICIENT_BUFFER: Buffer is too small to hold data.',
    SCARD_E_UNKNOWN_READER: 'SCARD_E_UNKNOWN_READER: The reader is unknown or unavailable.',
    SCARD_E_TIMEOUT: 'SCARD_E_TIMEOUT: The operation timed out.',
    SCARD_E_SHARING_VIOLATION: 'SCARD_E_SHARING_VIOLATION: Another application is using the smart card.',
    SCARD_E_NO_SMARTCARD: 'SCARD_E_NO_SMARTCARD: No smart card is present in the reader.',
    SCARD_E_UNKNOWN_CARD: 'SCARD_E_UNKNOWN_CARD: The card inserted is unknown.',
    SCARD_E_CANT_DISPOSE: 'SCARD_E_CANT_DISPOSE: Unable to dispose of the resource.',
    SCARD_E_PROTO_MISMATCH: 'SCARD_E_PROTO_MISMATCH: Protocol mismatch detected.',
    SCARD_E_NOT_READY: 'SCARD_E_NOT_READY: The device is not ready for communication.',
    SCARD_E_INVALID_VALUE: 'SCARD_E_INVALID_VALUE: An invalid value was provided.',
    SCARD_E_SYSTEM_CANCELLED: 'SCARD_E_SYSTEM_CANCELLED: The operation was canceled by the system.',
    SCARD_F_COMM_ERROR: 'SCARD_F_COMM_ERROR: Communication error occurred.',
    SCARD_F_UNKNOWN_ERROR: 'SCARD_F_UNKNOWN_ERROR: An unknown error occurred.',
    SCARD_E_INVALID_ATR: 'SCARD_E_INVALID_ATR: The ATR (Answer to Reset) is invalid.',
    SCARD_E_NOT_TRANSACTED: 'SCARD_E_NOT_TRANSACTED: The transaction was not completed.',
    SCARD_E_READER_UNAVAILABLE: 'SCARD_E_READER_UNAVAILABLE: The reader is unavailable.',
    SCARD_P_SHUTDOWN: 'SCARD_P_SHUTDOWN: The system is shutting down.',
    SCARD_E_PCI_TOO_SMALL: 'SCARD_E_PCI_TOO_SMALL: The PCI (Peripheral Component Interconnect) size is too small.',
    SCARD_E_READER_UNSUPPORTED: 'SCARD_E_READER_UNSUPPORTED: The reader is not supported.',
    SCARD_E_DUPLICATE_READER: 'SCARD_E_DUPLICATE_READER: Duplicate reader detected.',
    SCARD_E_CARD_UNSUPPORTED: 'SCARD_E_CARD_UNSUPPORTED: The card is not supported.',
    SCARD_E_NO_SERVICE: 'SCARD_E_NO_SERVICE: The service is not available.',
    SCARD_E_SERVICE_STOPPED: 'SCARD_E_SERVICE_STOPPED: The service has been stopped.',
    SCARD_E_UNEXPECTED: 'SCARD_E_UNEXPECTED: An unexpected error occurred.',
    SCARD_E_ICC_INSTALLATION: 'SCARD_E_ICC_INSTALLATION: Installation of ICC (Integrated Circuit Card) failed.',
    SCARD_E_ICC_CREATEORDER: 'SCARD_E_ICC_CREATEORDER: Failed to create ICC order.',
    SCARD_E_UNSUPPORTED_FEATURE: 'SCARD_E_UNSUPPORTED_FEATURE: The feature is not supported.',
    SCARD_E_DIR_NOT_FOUND: 'SCARD_E_DIR_NOT_FOUND: The directory could not be found.',
    SCARD_E_FILE_NOT_FOUND: 'SCARD_E_FILE_NOT_FOUND: The file could not be found.',
    SCARD_E_NO_DIR: 'SCARD_E_NO_DIR: No directory available.',
    SCARD_E_NO_FILE: 'SCARD_E_NO_FILE: No file available.',
    SCARD_E_NO_ACCESS: 'SCARD_E_NO_ACCESS: No access to the requested resource.',
    SCARD_E_WRITE_TOO_MANY: 'SCARD_E_WRITE_TOO_MANY: Too many writes attempted.',
    SCARD_E_BAD_SEEK: 'SCARD_E_BAD_SEEK: Invalid seek operation.',
    SCARD_E_INVALID_CHV: 'SCARD_E_INVALID_CHV: Invalid cardholder verification value.',
    SCARD_E_UNKNOWN_RES_MNG: 'SCARD_E_UNKNOWN_RES_MNG: Unknown resource manager.',
    SCARD_E_NO_SUCH_CERTIFICATE: 'SCARD_E_NO_SUCH_CERTIFICATE: Certificate not found.',
    SCARD_E_CERTIFICATE_UNAVAILABLE: 'SCARD_E_CERTIFICATE_UNAVAILABLE: Certificate unavailable.',
    SCARD_E_NO_READERS_AVAILABLE: 'SCARD_E_NO_READERS_AVAILABLE: No readers available for communication.',
    SCARD_E_COMM_DATA_LOST: 'SCARD_E_COMM_DATA_LOST: Communication data lost.',
    SCARD_E_NO_KEY_CONTAINER: 'SCARD_E_NO_KEY_CONTAINER: No key container available.',
    SCARD_E_SERVER_TOO_BUSY: 'SCARD_E_SERVER_TOO_BUSY: The server is too busy to handle the request.',
    SCARD_W_UNSUPPORTED_CARD: 'SCARD_W_UNSUPPORTED_CARD: The card is unsupported.',
    SCARD_W_UNRESPONSIVE_CARD: 'SCARD_W_UNRESPONSIVE_CARD: The card is unresponsive.',
    SCARD_W_UNPOWERED_CARD: 'SCARD_W_UNPOWERED_CARD: The card is not powered.',
    SCARD_W_RESET_CARD: 'SCARD_W_RESET_CARD: The card was reset.',
    SCARD_W_REMOVED_CARD: 'SCARD_W_REMOVED_CARD: The card was removed.',
    SCARD_W_SECURITY_VIOLATION: 'SCARD_W_SECURITY_VIOLATION: A security violation occurred.',
    SCARD_W_WRONG_CHV: 'SCARD_W_WRONG_CHV: Wrong cardholder verification value.',
    SCARD_W_CHV_BLOCKED: 'SCARD_W_CHV_BLOCKED: Cardholder verification value blocked.',
    SCARD_W_EOF: 'SCARD_W_EOF: End of file reached.',
    SCARD_W_CANCELLED_BY_USER: 'SCARD_W_CANCELLED_BY_USER: The operation was canceled by the user.',
    SCARD_W_CARD_NOT_AUTHENTICATED: 'SCARD_W_CARD_NOT_AUTHENTICATED: The card was not authenticated.',
  };

  static String returnCodeToString(int code) {
    return returnCodeMap[code] ?? 'Unknown error $code';
  }

}