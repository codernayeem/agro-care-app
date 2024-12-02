class Status {
  bool success;
  String message;

  Status({required this.success, required this.message});
  Status.success({this.success = true, this.message = ""});
  Status.fail({this.success = false, required this.message});
}
