class ValidationMixing {
  String validateEmail(String val) {
    if (val.contains("@") && val.contains(".")) return null;
    return "Email address not valid";
  }

  String validatePassword(String val) {
    if (val.length >= 2) return null;
    return "Password too short";
  }

  String isEmptyValidation(String val) {
    if (val.isNotEmpty) return null;
    return "Cannot be empty";
  }
}
