# KPP-02 Navigation Contract

## Shared mental model

Mobile and desktop use the same five labels: **TODAY / ASK DUTA / ESSENTIAL /
CONNECT / ME**. Labels, conceptual homes and active-state rules do not change by
viewport. Valid capabilities remain available through contextual links and
progressive disclosure.

## Mobile

The bottom navigation contains all five intents. ASK DUTA occupies the central,
emphasized position because it is the fastest intent router, but it is not
larger at the expense of accessible labeling or thumb reach:

1. TODAY
2. ESSENTIAL
3. ASK DUTA
4. CONNECT
5. ME

Jaga Diri is a persistent high-contrast shell action outside the five equal
intent slots, reachable in one tap without opening a menu. It must not be
represented only as an ESSENTIAL tile.

## Desktop

The primary sidebar/header contains the same five intents in the same conceptual
order, with a persistent Jaga Diri action. Secondary navigation appears within
the active intent, not as a ten-module global list. The location/context control
is not global truth: it displays coarse context only when established and offers
an honest unset state.

## Navigation layers

- **Primary:** five intents plus persistent Jaga Diri.
- **Secondary:** intent-level destinations, such as Layanan RI/Kerja under
  ESSENTIAL and Komuniti/Organisasi under CONNECT.
- **Contextual:** result/detail actions, related official destinations and
  return-to-result links.
- **Authenticated-only:** saved, continue, managed organizations, privacy,
  permissions, security and logout under ME.
- **Internal:** admin links never appear in consumer navigation.

## Behavioral rules

- Browser back preserves query, filters, scroll and safe draft state where
  feasible; route transitions do not silently reset context.
- Deep links open their target directly; Auth-required actions preserve an
  allowlisted `returnTo` and resume after Auth.
- Empty/error states offer a parent-intent path and one relevant alternative.
- Locked/deferred capabilities never fill navigation symmetry.
- Active state covers descendants (for example `/organisasi/[id]` keeps
  CONNECT active), unlike the current exact-path-only behavior.
- Public ME opens Auth entry; authenticated ME opens the control center.

## Retirement target

Retire the ten-item global sidebar, first-five mobile slice, landing feature
catalog as navigation authority, global bell without a working notifications
contract, search icon that merely aliases ASK DUTA, and public Preview admin
link. Retirement is later implementation work, not performed by KPP-02.
