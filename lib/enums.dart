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
