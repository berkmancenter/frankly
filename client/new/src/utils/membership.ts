import type { MembershipStatus } from '@/api/types';

/** Port of `MembershipStatusExtension` (membership.dart): each level implies the ones below it. */
const RANK: Record<MembershipStatus, number> = {
  banned: 0,
  nonmember: 1,
  attendee: 2,
  member: 3,
  facilitator: 4,
  moderator: 5,
  admin: 6,
  owner: 7,
};

export const isNotBanned = (s: MembershipStatus) => s !== 'banned';
export const isMember = (s: MembershipStatus) => RANK[s] >= RANK.member;
export const isFacilitator = (s: MembershipStatus) => RANK[s] >= RANK.facilitator;
export const isMod = (s: MembershipStatus) => RANK[s] >= RANK.moderator;
export const isAdmin = (s: MembershipStatus) => RANK[s] >= RANK.admin;

export const roleLabel = (s: MembershipStatus): string =>
  ({
    owner: 'Owner',
    admin: 'Admin',
    moderator: 'Moderator',
    facilitator: 'Facilitator',
    member: 'Member',
    banned: 'Banned',
    nonmember: 'Non-member',
    attendee: 'Attendee',
  })[s];
