/** Same rule as Flutter's `isEmailValid`. */
export function isEmailValid(email: string): boolean {
  return /^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+/.test(
    email,
  );
}

/** At least 12 characters, with one lowercase and one uppercase letter. Only enforced at sign-up. */
export function isPasswordValid(password: string): boolean {
  return /^(?=.*?[A-Z])(?=.*?[a-z]).{12,}$/.test(password);
}
