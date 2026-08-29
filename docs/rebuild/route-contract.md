# Route contract carried over from the pre-redesign client

The screens were deleted; these URLs were not invented with them. They encode
deep-link shape, Web refresh/back behaviour and the invitation entry point, all
of which the rebuilt screens must preserve.

The original `router.dart` and `nav_shell.dart` are archived beside this file.

## Paths

- `/today`
- `/start`
- `/dynamics/:id/today`
- `/sign-in`
- `/invite/:token`
- `/dynamics/:id`
- `/dynamics/:id/separate`
- `/dynamics/:id/us`
- `/dynamics/:id/attention`
- `/dynamics/:id/ask`
- `/dynamics/:id/invite`
- `/dynamics/:id/rhythm`
- `/dynamics/:id/explore`
- `/settings/notifications`
- `/auth/callback`
- `/occurrences/:id`

## Rules that were encoded in the router

- Bottom navigation is exactly four tabs: Today · Dynamic · Explore · Us.
- `/invite/:token` must resolve for an anonymous visitor. Opening an invitation
  is not joining, and signing in happens on the invitation itself.
- A member with one Dynamic is routed straight into it; a member with several
  chooses by person, never by id.
- Web must support refresh, browser back and direct URL entry for every path.
