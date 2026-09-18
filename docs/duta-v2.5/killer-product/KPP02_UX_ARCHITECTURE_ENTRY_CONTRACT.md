# KPP-02 UX Architecture Entry Contract

Date: 2026-09-18
Authority: KPP-01A founder decisions FD-01 through FD-05.
Purpose: authoritative inputs for KPP-02; this document is not the KPP-02
architecture and does not authorize implementation.

## Target users

Indonesian residents and new arrivals in Malaysia who need fast, trustworthy,
mobile-first access to official services, safety guidance, work discovery,
community and organization discovery, and bounded DUTA assistance. The design
must also support returning authenticated users without making an account a
precondition for low-risk public value.

## Public-vs-Auth boundary

The product is VALUE BEFORE LOGIN. Public users can access official-service
navigation, Jaga Diri information/safety, Kerja, Komuniti, Organisasi and
appropriate place/service discovery, plus a bounded non-persistent DUTA
experience. Authentication is required for save, join, create, submit,
personalize, persisted continuation, profile and organization management,
user-generated content and other identity-bound actions. Never weaken mutation
or authorization controls to make a capability public.

## Auth contract

Google OAuth is primary. Passwordless email magic link is the fallback. Existing
email/password sign-in may remain temporarily only for compatible existing
accounts and must not be the primary new-user journey. Phone OTP, WhatsApp OTP
and Google One Tap are deferred. Use Supabase-native account linking only after
explicit collision and duplicate-account testing.

## Onboarding principles

Show useful public value before asking for identity. After identity, request
only the minimum context needed for the selected action; keep coarse city and
intent skippable where possible. Explain purpose, allow safe skip/recovery and
avoid redundant collection. Do not request precise location during generic
onboarding.

## Primary intents

The primary intent model is **TODAY / ASK DUTA / ESSENTIAL / CONNECT / ME**.
KPP-02 determines evidence-based mobile and desktop representation and route
grouping without deleting valid underlying modules.

## Jaga Diri rule

Jaga Diri is a persistent safety shortcut and trust anchor. It must remain
rapidly accessible even when related services are grouped under ESSENTIAL. Do
not bury urgent or safety access several levels deep.

## Progressive disclosure rule

Expose the next relevant action first and disclose supporting modules and
advanced controls progressively. Locked, deferred, empty or unavailable modules
must not receive misleading primary prominence. Preserve deep links and clearly
label honest unavailable states where appropriate.

## Commercialization boundary

Initial v2.5 launch offers free organization presence. Paid purchase CTAs are
hidden/not launch-active and public paid package pricing is deferred. Internal
pricing or entitlement logic does not authorize public commercialization.

## Age policy

Public informational access requires no age collection by default. Apply
lightweight 18+ self-attestation at account creation and identity-bound user
actions, including user-generated content, where required by current policy.
Do not collect full date of birth or unnecessary birth-year data by default.
The mechanism is subject to legal review before release.

## Regulatory launch locks

Pasar transaction/seller activation, finance execution, health functionality,
e-voting, CCTV, MyDigital ID and uncontrolled Citizen Report publishing remain
locked or deferred. Kerja is discovery/referral, not placement. KBRI/KJRI and
official services are navigation/referral; official systems execute. Citizen
Report remains private/moderator-first. Precise location is restricted.

## Privacy and data-minimization rules

Collect only data necessary for an explicit current action. Use coarse location
for discovery and request precise browser location only with an action-specific
reason and explicit permission; keep it device-local/default off where the
contract requires. No default full DOB. Provider, consent, retention, recovery,
deletion and account-linking consequences must be clear.

## Trust requirements

Official, verified, community, user-report and AI-guidance labels require
distinct evidence predicates. Show source authority, freshness, executor
boundary and AI limitations consistently. Never manufacture personalization,
availability, verification or official jurisdiction.

## Mobile-first requirement

The architecture must work first on common low-end mobile viewports, with
touch-accessible targets, resilient slow/denied/offline states and no desktop
navigation assumption. Voice is optional; every essential path remains
text-complete.

## Zero-training objective

A first-time user must identify the product's purpose, obtain public value and
reach the next safe action without instruction, prior product knowledge or
module vocabulary.

## Five-second comprehension objective

Within five seconds, the first viewport must communicate whom DUTA RANTAU serves,
the immediate value available, the primary action and its independent/non-
government boundary. KPP-02 must validate this objective with architecture
evidence rather than visual polish alone.
