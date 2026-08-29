# UI invariants carried over from the pre-redesign client

The screens were deleted and are being rebuilt against the approved design
system. The behaviour below was asserted by 15 widget test files that went with
them. It is recorded here because these are not styling preferences — each line
is a product red line in executable form, and several of them caught real
defects during the pre-redesign build.

**Every rebuilt screen must restore the invariants for its surface, as tests,
before it can be considered done.** A screen that renders correctly and drops
one of these has regressed the product, not just its coverage.

Source: `client/test/features/` at commit before the redesign; recoverable from
git history and from `dsapp-legacy-history.bundle`.


## adjustment ui

- all three asks are offered together
- it states plainly that none of this is a miss
- the note is OPTIONAL - no reason is demanded
- no apology or failure language anywhere
- sending requires choosing something first
- the chosen type reaches the caller
- never uses approve or reject language
- the requester is named and their words shown verbatim
- backend state names never leak
- letting it go is offered as a clean ending
- rescheduling says the original stays on the record
- the chosen resolution reaches the caller
- the answer matching the request comes first

## attention screen

- empty Attention is presented as a good state, not a void
- renders server order, never re-sorted by recency
- a completion is attributed to the person, not the task
- backend state names never leak to the user
- count copy is singular for one item
- no gamification vocabulary
- priority is spatial, not just a sort order
- empty bands are not shown
- answering happens in the list, not on another page
- the inline composer will not send words nobody wrote
- only one composer is open at a time

## checkin starter

- PRIVATE is the default - sharing is a deliberate act
- the visibility choice is visible, not buried in settings
- choosing Share changes both the button and what is sent
- nothing is required - an empty check-in can be saved
- no judgement vocabulary
- uses the canonical copy contract
- shows exactly three things by default
- the second expectation is OPT-IN, unchecked by default
- starting passes the opt-in choice through
- reassures that nothing here is permanent
- no gamification or obligation vocabulary

## home resolver

- a member with one dynamic is taken straight there
- a member with no dynamic gets a real next step, not a 
- it also points at the other way in
- several dynamics are named by person, never by id
- a dynamic nobody has joined yet says so
- a failure offers a way back, not a dead end

## join threshold

- signing in happens on the invitation itself
- it says plainly that signing in is not joining
- the trust answers still come before the threshold
- opening the invitation never joins by itself

## nav shell

- every Core Beta surface is reachable
- the tabs are the canonical four, in order
- the active tab is marked, and only one is
- before a dynamic exists the bar still renders

## quick sign in

- quick sign-in requests a real link and routes to the 

## quiet hours

- states that these settings are the member's own
- promises nothing is dropped while quiet
- shows the window in the member's own timezone
- neutral previews are the default and are described plainly
- a saved window is loaded, not overwritten by defaults
- refuses a zero-length window instead of guessing
- turning quiet hours off clears both bounds
- no judgemental or gamified vocabulary

## red lines

- waiting screen says the moment is unfinished until a human responds
- the waiting screen names the person, not a workflow state
- waiting screen never claims the partner has already responded
- respond screen starts EMPTY — no pre-filled system words
- send is disabled until the human writes something
- suggestions are labelled as suggestions and only fill the field
- the person is never asked to classify their own words
- an untouched suggestion cannot be sent as your own words
- editing a suggestion down to nothing is not sendable either
- received screen attributes the words to the real sender
- no points, streaks, scores or trophies anywhere

## separation ui

- both actions are offered together and stated as always available
- Block reaches the server in TWO taps - no wizard, no typing
- Block discloses that it seals the ACTOR's own history too
- Block states the other person is not told who did it
- Leave says the partner KEEPS existing history
- either action can be backed out of
- after blocking it returns to an ordinary screen, with no fanfare
- no alarming or accusatory language anywhere
- a failure is recoverable, never a dead end

## sign in staging flag

- staging quick sign-in is OFF unless explicitly compiled in

## today screen

- the system never speaks in the Dom voice
- an expectation shows who it came from
- a recent human response is shown verbatim and attributed
- no response yet means nothing warm is fabricated
- completing is not being seen
- backend state names never leak
- empty Today is stated plainly, not padded with filler
- no gamification vocabulary

## today two faces

- the receiving side sees no direction-giving entry
- the direction-giving side is offered the way in
- both faces can appear at once
- a partner's words outrank the routing row
- it says a person is waiting, never that something is late
- an empty day is still stated when nothing needs anyone

## us dynamic screen

- a human response is shown verbatim and attributed
- connected days are stated as a fact, never as a score
- backend event names never leak
- empty Us invites rather than scolds
- inviolable agency is ALWAYS shown, never behind a menu
- Core Beta shows no Agreement, Rules or permissions matrix
- either member can pause — the button is always offered
- a paused dynamic promises there is nothing to catch up on
- pausing calls the command with an idempotency key
- Always yours renders in full even when the server sends none
- it sits with the relationship, not at the bottom
- an unknown backend value never reaches the user

## weekly decision

- adjust and pause are actions, not sentences
- keeping the rhythm is stated, not a button
- no decision is offered before there is a week to reflect on
- an empty history does not swallow the reflection
- the decision is never framed as a verdict on the week

## weekly reflection

- stays hidden until the couple has a week behind them
- describes the week by what was answered
- the reflection synthesises; it never quotes a moment
- never grades the week
- never names a shortfall or implies disobedience
- offers no verdict — the decision stays with the couple
- no question is asked when it cannot be answered
- never quotes words the history below already shows
- states the connected-day count exactly once
- a failed reflection load never breaks the history below it

