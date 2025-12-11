import 'dart:async';

import 'package:pcsc_wrapper/pcsc_wrapper.dart';

Future<void> main() async {
  final pcsc = PCSCWrapper();
  SCardContext? context;
  try {
    // Typically, SCARD_SCOPE_SYSTEM is defined as 2.
    final establishResult = await pcsc.establishContext(2);
    if (!establishResult.result.isSuccess) {
      print("Failed to establish context: ${establishResult.result.message}");
      return;
    }
    context = establishResult.context;
    print("Context established: ${context.hContext}");

    // List the available readers for the established context.
    final readersResult = await pcsc.listReaders(context.hContext);
    if (!readersResult.result.isSuccess) {
      print("Failed to list readers: ${readersResult.result.message}");
      return;
    }
    
    final readers = readersResult.readers;
    if (readers.isEmpty) {
      print("No readers found.");
    } else {
      print("Readers found:");
      for (final reader in readers) {
        print(" - $reader");
      }

      await monitorReaderEvents(pcsc, context, readers.first);
    }
  } catch (e) {
    print("Error: $e");
  } finally {
    if (context != null) {
      try {
        await pcsc.releaseContext(context);
        print("Context released.");
      } catch (e) {
        print("Error releasing context: $e");
      }
    }
    pcsc.dispose();
  }
}


/// Monitors the given reader for card insertion and removal events.
/// Uses an infinite timeout to block until an event occurs.
Future<void> monitorReaderEvents(
  PCSCWrapper pcsc,
  SCardContext context,
  String readerName,
) async {
  print("Monitoring reader '$readerName' for card events...");

  // Start with an initial state where the application is unaware of the reader's state.
  int initialState = PcscConstants.SCARD_STATE_UNAWARE;
  SCardReaderState state = SCardReaderState(readerName, initialState, 0, []);

  // Loop indefinitely. (Consider adding cancellation logic if necessary.)
  while (true) {
    try {
      // Wait indefinitely using the SCARD_INFINITE constant.
      final statusResult = await pcsc.getStatusChange(
          context.hContext, PcscConstants.SCARD_INFINITE, [state]);

      if (!statusResult.result.isSuccess) {
        print("getStatusChange failed: ${statusResult.result.message}");
        break;
      }

      // getStatusChange returns an updated state.
      SCardReaderState newState = statusResult.readerStates[0];

      // Check if the state has changed.
      if (newState.dwEventState != state.dwCurrentState) {
        // Detect card insertion.
        if ((newState.dwEventState & PcscConstants.SCARD_STATE_PRESENT) != 0 &&
            (state.dwCurrentState & PcscConstants.SCARD_STATE_PRESENT) == 0) {
          print("Card inserted in reader '$readerName'.");
        }

        // Detect card removal.
        if ((newState.dwEventState & PcscConstants.SCARD_STATE_EMPTY) != 0 &&
            (state.dwCurrentState & PcscConstants.SCARD_STATE_EMPTY) == 0) {
          print("Card removed from reader '$readerName'.");
        }

        // For debugging: print the new event state.
        print(
            "New reader event state: 0x${newState.dwEventState.toRadixString(16)}");

        // Update the state for the next iteration.
        state = SCardReaderState(
            readerName,
            newState.dwEventState,
            newState.dwEventState,
            newState.rgbAtr);
      }
    } catch (e) {
      print("Error during getStatusChange: $e");
      break; // Exit on error, or you could add more advanced error handling.
    }
  }
}
