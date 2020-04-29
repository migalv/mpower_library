import 'package:flutter/material.dart';

const background = const Color(0xFFF4F4F4);

MaterialColor primarySwatch = MaterialColor(primary50.value, swatch1);
Map<int, Color> swatch1 = {
  50: primary50,
  100: primary100,
  200: primary200,
  300: primary300,
  400: primary400,
  500: primary500,
  600: primary600,
  700: primary700,
  800: primary800,
  900: primary900,
};
const primary50 = const Color(0xFFFFFFFF);
const primary100 = const Color(0xFFF7F7F7);
const primary150 = const Color(0xFFEBEBEB);
const primary200 = const Color(0xFFDEDEDE);
const primary300 = const Color(0xFFC3C3C3);
const primary400 = const Color(0xFFAAAAAA);
const primary500 = const Color(0xFF8B8B8B);
const primary600 = const Color(0xFF717171);
const primary700 = const Color(0xFF575757);
const primary800 = const Color(0xFF3D3D3D);
const primary900 = const Color(0xFF303030);
const primaryMain = primary50;

MaterialColor secondarySwatch = MaterialColor(secondary500.value, swatch2);
Map<int, Color> swatch2 = {
  50: secondary50,
  100: secondary100,
  200: secondary200,
  300: secondary300,
  400: secondary400,
  500: secondary500,
  600: secondary600,
  700: secondary700,
  800: secondary800,
  900: secondary900,
};
const secondary50 = const Color(0xFFFFF8E1);
const secondary100 = const Color(0xFFFFECB3);
const secondary200 = const Color(0xFFFFE082);
const secondary300 = const Color(0xFFFFD54F);
const secondary400 = const Color(0xFFFFCA28);
const secondary500 = const Color(0xFFFFC107);
const secondary600 = const Color(0xFFFFB300);
const secondary700 = const Color(0xFFFFA000);
const secondary800 = const Color(0xFFFF8F00);
const secondary900 = const Color(0xFFFF6F00);
const secondaryMain = secondary500;
const disabledColor = const Color(0xFFD3BD7A);

/// ORDER-STOCK UNIT colors
// Online
const statusWaiting = Colors.red;
const statusReady = const Color(0xFF3F51B5);
const statusLinked = const Color(0xFFFFCA28);
const statusDelivering = Colors.orange;
const statusDelivered = Colors.green;
const statusMoving = const Color(0xFF78909C);
const statusCanceled = const Color(0xFF212121);
const statusReturned = Colors.deepPurple;
// Offline
const statusWaitingOffline = const Color(0xFFFBBFBA);
const statusReadyOffline = const Color(0xFFBDC4E6);
const statusLinkedOffline = const Color(0x56FFCA28);
const statusDeliveringOffline = const Color(0xFFFFEDB6);
const statusDeliveredOffline = const Color(0xFFC2E4C3);
const statusMovingOffline = const Color(0xFFD1D9DD);
const statusCanceledOffline = const Color(0xFF878787);
const statusReturnedOffline = const Color(0xFFB39DDB);

/// INVENTORY RECOUNT colors
// Online
const statusNotStarted = Colors.blueGrey;
const statusInProgress = Colors.lightBlue;
const statusPaused = Colors.orange;
const statusError = Colors.red;
const statusSuccess = Colors.green;
const statusFinished = Colors.black54;
const statusProcessing = const Color(0xFF3F51B5);
// Offline
const statusNotStartedOffline = const Color(0xFFB0BEC5);
const statusInProgressOffline = const Color(0xFFE0F4FD);
const statusPausedOffline = const Color(0xFFFFF2E0);
const statusSuccessOffline = const Color(0xFFC2E4C3);
const statusErrorOffline = const Color(0xFFFBBFBA);
const statusFinishedOffline = Colors.black54;
const statusProcessingOffline = const Color(0xFF6A78C9);

/// TICKETING SYSTEM colors
// Open
const lowPriority = const Color(0xFF1F9D55);
const mediumPriority = const Color(0xFFF2D024);
const highPriority = const Color(0xFFCC1F1a);
// Closed
const lowPriorityClosedColor = const Color(0xFF416B53);
const mediumPriorityClosedColor = const Color(0xFFBBA94A);
const highPriorityClosedColor = const Color(0xFF8D322F);
// Offline
const lowPriorityOffline = const Color(0x8A1F9D55);
const mediumPriorityOffline = const Color(0x8AF2D024);
const highPriorityOffline = const Color(0x8ACC1F1a);
// Chip
const lowPriorityOfflineChipColor = const Color(0xFF1A8149);
const mediumPriorityOfflineChipColor = const Color(0xFFDABB48);
const highPriorityOfflineChipColor = const Color(0xFFB61C18);

const openTicketStatusColor = const Color(0xFF2485E7);
const closedTicketStatusColor = const Color(0xFF3D3D3D);

const black1 = const Color(0x01000000);
const black2 = const Color(0x04000000);
const black3 = const Color(0x06000000);
const black4 = const Color(0x09000000);
const black5 = const Color(0x0B000000);
const black6 = const Color(0x10000000);
const black18 = const Color(0x2E000000);
const black60 = const Color(0x99000000);
const black70 = const Color(0xB3000000);

const errorColor = const Color(0xFFB00020);
