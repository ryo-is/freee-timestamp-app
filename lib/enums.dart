enum Status { working, workout, rest }

String statusToString(Status status) {
  switch (status) {
    case Status.working:
      return "出勤中";
    case Status.workout:
      return "退勤済";
    case Status.rest:
      return "休憩中";
    default:
      return "";
  }
}

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
