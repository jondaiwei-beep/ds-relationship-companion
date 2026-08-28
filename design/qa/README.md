# Visual QA

For each approved screen, store the design reference, implementation render, and visual difference evidence. Reference mobile renders use 390 × 844 logical pixels. Texture may use a controlled mask; typography, geometry, copy, SVG shape, state visibility, and interaction hierarchy require strict comparison.

`reference/activation-flow-rev2-board.jpg` is the current four-step setup candidate review board: Goal → Mode/Role → Structure/Context → Starter Rhythm. It is review evidence, not a substitute for each screen's lossless source and contract.

`reference/connected-loop-invite-response-board.jpg` is the connected-loop candidate review board: Invite Pending → Web Join Trust → Complete/Waiting → Acknowledgement Composer. It is review evidence, not a substitute for state variants or screen contracts.

`reference/invite-lifecycle-rev2-board.jpg` reviews the Invite/Join lifecycle family: creator Accepted → creator Expired → creator Revoked → invitee Expired safe landing → Auth Return. It verifies shared visual grammar and distinct permission-aware content.

`reference/svg-freeze-v1-board.png` is the canonical overview of all 33 native SVG masters. `reference/svg-freeze-v1-botanical-board.png` provides enlarged QA for the three restrained decorative motifs. `reference/svg-freeze-v1-validation.json` records the parse/render and source-policy checks; regenerate all three with `design/qa/scripts/render-svg-freeze.cjs`.
