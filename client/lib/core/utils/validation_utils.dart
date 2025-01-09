bool isEmailValid(String email) {
  if (email.contains('@') && email.contains('.')) {
    return true;
  }

  return false;
}
