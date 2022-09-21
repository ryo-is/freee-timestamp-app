import 'package:flutter/material.dart';

enum AvailableType { clockIn, breakBegin, breakEnd, clockOut }

String availableTypeToString(AvailableType type) {
  switch (type) {
    case AvailableType.clockIn:
      return 'clock_in';
    case AvailableType.breakBegin:
      return 'break_begin';
    case AvailableType.breakEnd:
      return 'break_end';
    case AvailableType.clockOut:
      return 'clock_out';
  }
}

enum ResponseStatus { loading, success, error }

Widget responseStatusIcon(ResponseStatus status) {
  switch (status) {
    case ResponseStatus.loading:
      return const CircularProgressIndicator();
    case ResponseStatus.success:
      return const Icon(
        Icons.done,
        color: Colors.green,
        size: 48,
      );
    case ResponseStatus.error:
      return const Icon(
        Icons.close,
        color: Colors.red,
        size: 48,
      );
  }
}
