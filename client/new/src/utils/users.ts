/** "Ada Lovelace" -> "Ada L"; a single word stays as is. Port of `firstAndLastInitial` (data_models). */
export function firstAndLastInitial(
  fullName: string | null | undefined,
): string | null {
  if (!fullName) return null;
  const parts = fullName.split(" ");
  const lastInitial = parts[parts.length - 1]?.[0];
  if (parts.length === 1 || !lastInitial) return parts[0] ?? null;
  return `${parts[0]} ${lastInitial}`;
}

/**
 * Non-cryptographic hash from a uid to a 30-bit integer, used as the Agora id. Must match
 * `uidToInt` in data_models/lib/utils/utils.dart, since the server and Flutter client compute it too.
 */
export function uidToInt(uid: string): number {
  const base = 257;
  const mod = 1 << 30;
  let hash = 0;
  for (let i = 0; i < uid.length; i++) {
    hash = (hash * base + uid.charCodeAt(i)) % mod;
  }
  return hash;
}

/**
 * The public display name for a new account, in the same order of preference as Flutter's
 * `getDefaultPublicUserInfo`: name given at sign-up, then the auth profile name, then the email
 * address, then `User-xxxx`.
 */
export function defaultDisplayName(input: {
  uid: string;
  registrationName?: string | null;
  profileName?: string | null;
  email?: string | null;
}): string {
  return (
    firstAndLastInitial(input.registrationName) ??
    firstAndLastInitial(input.profileName) ??
    firstAndLastInitial(input.email) ??
    `User-${input.uid.slice(0, 4)}`
  );
}
